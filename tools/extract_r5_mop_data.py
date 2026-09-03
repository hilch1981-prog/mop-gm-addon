#!/usr/bin/env python3
from __future__ import annotations
import argparse, collections, json, re, zipfile
from pathlib import Path

TARGET_TABLES = {
    'quest_template', 'creature_queststarter', 'creature_questender',
    'gameobject_queststarter', 'gameobject_questender',
    'creature', 'gameobject', 'creature_template', 'gameobject_template',
    'locales_creature', 'locales_gameobject', 'creature_template_locale', 'gameobject_template_locale',
    'creature_loot_template', 'gameobject_loot_template', 'game_tele',
}

def sql_unquote(token: str):
    token = token.strip()
    if not token or token.upper() == 'NULL': return None
    if token[0:1] == "'" and token[-1:] == "'":
        s = token[1:-1]; out=[]; i=0
        trans={'0':'\0','n':'\n','r':'\r','t':'\t','b':'\b','Z':'\x1a'}
        while i < len(s):
            c=s[i]
            if c=='\\' and i+1 < len(s):
                i+=1; c=s[i]; out.append(trans.get(c,c)); i+=1
            elif c=="'" and i+1 < len(s) and s[i+1]=="'":
                out.append("'"); i+=2
            else: out.append(c); i+=1
        return ''.join(out)
    if token.lower().startswith('0x'): return token
    try:
        if any(c in token for c in '.eE'): return float(token)
        return int(token)
    except Exception: return token

def split_values(body: str):
    rows=[]; i=0; n=len(body)
    while i<n:
        while i<n and body[i] != '(': i+=1
        if i>=n: break
        i+=1; vals=[]; start=i; quote=False; esc=False; depth=1
        while i<n and depth:
            c=body[i]
            if quote:
                if esc: esc=False
                elif c=='\\': esc=True
                elif c=="'":
                    if i+1<n and body[i+1]=="'": i+=1
                    else: quote=False
            else:
                if c=="'": quote=True
                elif c=='(': depth+=1
                elif c==')':
                    depth-=1
                    if depth==0:
                        vals.append(sql_unquote(body[start:i])); i+=1; break
                elif c==',' and depth==1:
                    vals.append(sql_unquote(body[start:i])); start=i+1
            i+=1
        if vals: rows.append(vals)
    return rows

def iter_statements(path: Path):
    with path.open('r', encoding='utf-8', errors='replace') as fh:
        buf=[]; active=False; quote=False; esc=False
        for line in fh:
            if not active:
                stripped=line.lstrip()
                m=re.match(r'(?:CREATE TABLE|INSERT(?: IGNORE)? INTO|REPLACE INTO|UPDATE)\s+`?([A-Za-z0-9_]+)`?', stripped, re.I)
                if not m or m.group(1).lower() not in TARGET_TABLES: continue
                active=True; buf=[]; quote=False; esc=False
            buf.append(line)
            for c in line:
                if quote:
                    if esc: esc=False
                    elif c=='\\': esc=True
                    elif c=="'": quote=False
                else:
                    if c=="'": quote=True
                    elif c==';':
                        yield ''.join(buf)
                        active=False; buf=[]; quote=False; esc=False
                        break
        if active and buf: yield ''.join(buf)

def parse_sources(paths):
    schemas={}; rows=collections.defaultdict(list); updates=[]; stats=collections.Counter()
    for path in paths:
        for stmt in iter_statements(path):
            s=stmt.lstrip()
            mc=re.match(r'CREATE TABLE\s+`?([A-Za-z0-9_]+)`?\s*\((.*)\)\s*;', s, re.I|re.S)
            if mc:
                schemas[mc.group(1).lower()]=re.findall(r'^\s*`([^`]+)`\s+', mc.group(2), re.M); continue
            mi=re.match(r'(?:INSERT(?: IGNORE)? INTO|REPLACE INTO)\s+`?([A-Za-z0-9_]+)`?\s*(?:\((.*?)\))?\s*VALUES\s*(.*);\s*$', s, re.I|re.S)
            if mi:
                table=mi.group(1).lower(); explicit=mi.group(2)
                cols=[x.strip().strip('`') for x in explicit.split(',')] if explicit else schemas.get(table, [])
                vals=split_values(mi.group(3)); stats[table]+=len(vals)
                if not cols: rows[table].extend(vals)
                else:
                    ncols=len(cols)
                    for v in vals:
                        if len(v)<ncols: v=v+[None]*(ncols-len(v))
                        rows[table].append({str(cols[i]).lower():v[i] for i in range(min(ncols,len(v)))})
                continue
            mu=re.match(r'UPDATE\s+`?([A-Za-z0-9_]+)`?\s+SET\s+(.*?)\s+WHERE\s+(.*);\s*$', s, re.I|re.S)
            if mu: updates.append((mu.group(1).lower(),mu.group(2),mu.group(3)))
    return schemas,rows,updates,stats

def get(row,*aliases,default=None):
    if not isinstance(row,dict): return default
    for a in aliases:
        if a.lower() in row and row[a.lower()] is not None: return row[a.lower()]
    return default

def to_int(v,default=0):
    try:return int(v)
    except:return default

def to_float(v,default=0.0):
    try:return float(v)
    except:return default

def esc_lua(s):
    return '"'+str(s or '').replace('\\','\\\\').replace('"','\\"').replace('\r',' ').replace('\n',' ')+'"'

def compact_spawn(row,kind,entry,name):
    return {'k':kind,'e':entry,'g':to_int(get(row,'guid')),'m':to_int(get(row,'map','mapid')),
            'x':round(to_float(get(row,'position_x','posx')),3),'y':round(to_float(get(row,'position_y','posy')),3),
            'z':round(to_float(get(row,'position_z','posz')),3),'n':name or ''}

def representative(spawns,maxn=3):
    out=[]
    for s in sorted(spawns,key=lambda x:(x['m'],x['g'])):
        if any(s['m']==o['m'] and abs(s['x']-o['x'])<5 and abs(s['y']-o['y'])<5 for o in out): continue
        out.append(s)
        if len(out)>=maxn: break
    return out

def lua_target(t):
    parts=[f'k={esc_lua(t["k"])}',f'e={t["e"]}',f'g={t["g"]}',f'm={t["m"]}',f'x={t["x"]}',f'y={t["y"]}',f'z={t["z"]}']
    if t.get('n'): parts.append('n='+esc_lua(t['n']))
    return '{'+','.join(parts)+'}'

def apply_updates(updates,creature_names,object_names,tele_names):
    for table,setpart,where in updates:
        idm=re.search(r'`?(?:entry|id)`?\s*=\s*(\d+)',where,re.I)
        if not idm: continue
        ident=int(idm.group(1)); assigns={}
        for m in re.finditer(r'`?([A-Za-z0-9_]+)`?\s*=\s*((?:\'(?:\\.|[^\'])*\')|[^,]+)',setpart,re.S):
            assigns[m.group(1).lower()]=sql_unquote(m.group(2).strip())
        if table in ('creature_template','locales_creature'):
            name=assigns.get('name_loc1') or assigns.get('name')
            if name: creature_names[ident]=str(name)
        elif table in ('gameobject_template','locales_gameobject'):
            name=assigns.get('name_loc1') or assigns.get('name')
            if name: object_names[ident]=str(name)
        elif table=='game_tele':
            name=assigns.get('name')
            if name: tele_names[ident]=str(name)

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--server',required=True); ap.add_argument('--out',required=True)
    ns=ap.parse_args(); server=Path(ns.server); out=Path(ns.out); out.mkdir(parents=True,exist_ok=True)
    world_zip=server/'sql/base/world_04_03_2023.zip'
    if not world_zip.exists(): raise SystemExit(f'missing {world_zip}')
    extract=out/'world_extract'; extract.mkdir(exist_ok=True)
    with zipfile.ZipFile(world_zip) as zf:
        sql_members=[m for m in zf.namelist() if m.lower().endswith('.sql')]
        if not sql_members: raise SystemExit('world zip has no sql')
        for m in sql_members: zf.extract(m,extract)
    paths=[extract/m for m in sql_members]+list((server/'repack/database/korean').glob('*.sql'))
    schemas,rows,updates,stats=parse_sources(paths)

    creature_names={}; creature_loot={}
    for r in rows.get('creature_template',[]):
        e=to_int(get(r,'entry','id'))
        if e: creature_names[e]=str(get(r,'name',default='') or ''); creature_loot[e]=to_int(get(r,'lootid','loot_id'))
    object_names={}; object_loot={}
    for r in rows.get('gameobject_template',[]):
        e=to_int(get(r,'entry','id'))
        if e: object_names[e]=str(get(r,'name',default='') or ''); object_loot[e]=to_int(get(r,'data1','lootid','loot_id'))
    for table,dest in [('locales_creature',creature_names),('locales_gameobject',object_names)]:
        for r in rows.get(table,[]):
            e=to_int(get(r,'entry','id')); name=get(r,'name_loc1','name_ko_kr','name_kokr')
            if e and name: dest[e]=str(name)
    for table,dest in [('creature_template_locale',creature_names),('gameobject_template_locale',object_names)]:
        for r in rows.get(table,[]):
            if str(get(r,'locale',default='')).lower()!='kokr': continue
            e=to_int(get(r,'entry','id')); name=get(r,'name')
            if e and name: dest[e]=str(name)
    tele_names={}
    for r in rows.get('game_tele',[]):
        e=to_int(get(r,'id','entry')); name=get(r,'name')
        if e and name: tele_names[e]=str(name)
    apply_updates(updates,creature_names,object_names,tele_names)

    csp=collections.defaultdict(list)
    for r in rows.get('creature',[]):
        e=to_int(get(r,'id','entry'))
        if e: csp[e].append(compact_spawn(r,'c',e,creature_names.get(e,'')))
    osp=collections.defaultdict(list)
    for r in rows.get('gameobject',[]):
        e=to_int(get(r,'id','entry'))
        if e: osp[e].append(compact_spawn(r,'o',e,object_names.get(e,'')))
    starters=collections.defaultdict(list); enders=collections.defaultdict(list)
    for table,kind,dest in [('creature_queststarter','c',starters),('gameobject_queststarter','o',starters),('creature_questender','c',enders),('gameobject_questender','o',enders)]:
        for r in rows.get(table,[]):
            e=to_int(get(r,'id','entry')); q=to_int(get(r,'quest','questid'))
            if q and e: dest[q].append((kind,e))
    c_loot_to_entries=collections.defaultdict(list)
    for e,lid in creature_loot.items():
        c_loot_to_entries[lid or e].append(e)
        if lid and lid!=e:c_loot_to_entries[e].append(e)
    o_loot_to_entries=collections.defaultdict(list)
    for e,lid in object_loot.items():
        o_loot_to_entries[lid or e].append(e)
        if lid and lid!=e:o_loot_to_entries[e].append(e)
    item_sources=collections.defaultdict(list)
    for table,kind,inverse in [('creature_loot_template','c',c_loot_to_entries),('gameobject_loot_template','o',o_loot_to_entries)]:
        for r in rows.get(table,[]):
            loot=to_int(get(r,'entry')); item=to_int(get(r,'item'))
            if item:
                for e in inverse.get(loot,[]): item_sources[item].append((kind,e))

    qdata={}; objective_slots=0
    def targets(pairs):
        vals=[]; seen=set()
        for k,e in pairs:
            if (k,e) in seen: continue
            seen.add((k,e)); src=csp.get(e,[]) if k=='c' else osp.get(e,[])
            vals.extend(representative(src,2) or [{'k':k,'e':e,'g':0,'m':0,'x':0,'y':0,'z':0,'n':creature_names.get(e,'') if k=='c' else object_names.get(e,'')}])
            if len(vals)>=6: break
        return vals[:6]
    for r in rows.get('quest_template',[]):
        q=to_int(get(r,'id','entry'))
        if not q: continue
        rec={}; st=targets(starters.get(q,[])); en=targets(enders.get(q,[]))
        if st: rec['s']=st
        if en: rec['e']=en
        objs=[]
        for i in range(1,5):
            raw=to_int(get(r,f'requirednpcorgo{i}',f'requirednpcorgoid{i}')); count=to_int(get(r,f'requirednpcorgocount{i}'),1)
            if raw:
                k='c' if raw>0 else 'o'; e=abs(raw); src=csp.get(e,[]) if k=='c' else osp.get(e,[])
                target=(representative(src,1) or [{'k':k,'e':e,'g':0,'m':0,'x':0,'y':0,'z':0,'n':creature_names.get(e,'') if k=='c' else object_names.get(e,'')}])[0]
                objs.append({'slot':i,'kind':k,'entry':e,'count':count,'target':target})
        for i in range(1,7):
            item=to_int(get(r,f'requireditemid{i}',f'reqitemid{i}')); count=to_int(get(r,f'requireditemcount{i}',f'reqitemcount{i}'),1)
            if item:
                source_targets=[]; seen=set()
                for k,e in item_sources.get(item,[]):
                    if (k,e) in seen: continue
                    seen.add((k,e)); src=csp.get(e,[]) if k=='c' else osp.get(e,[]); source_targets.extend(representative(src,1))
                    if len(source_targets)>=3: break
                objs.append({'slot':4+i,'kind':'i','item':item,'count':count,'sources':source_targets[:3]})
        if objs: rec['o']=objs; objective_slots+=len(objs)
        if rec:qdata[q]=rec

    with (out/'QuestLocations.lua').open('w',encoding='utf-8',newline='\n') as f:
        f.write('-- Generated from pinned MOP_V2_Repack world DB; do not edit by hand.\nAzerothAdminMoP548 = AzerothAdminMoP548 or {}\nAzerothAdminMoP548.MoPQuestLocations = {\n')
        for q in sorted(qdata):
            rec=qdata[q]; pieces=[]
            if rec.get('s'):pieces.append('s={'+','.join(lua_target(t) for t in rec['s'])+'}')
            if rec.get('e'):pieces.append('e={'+','.join(lua_target(t) for t in rec['e'])+'}')
            if rec.get('o'):
                op=[]
                for o in rec['o']:
                    p=[f's={o["slot"]}',f'k={esc_lua(o["kind"])}',f'c={o["count"]}']
                    if o.get('entry'):p.append(f'e={o["entry"]}')
                    if o.get('item'):p.append(f'i={o["item"]}')
                    if o.get('target'):p.append('t='+lua_target(o['target']))
                    if o.get('sources'):p.append('r={'+','.join(lua_target(t) for t in o['sources'])+'}')
                    op.append('{'+','.join(p)+'}')
                pieces.append('o={'+','.join(op)+'}')
            f.write(f'  [{q}]={{'+','.join(pieces)+'},\n')
        f.write('}\n')
    with (out/'TeleportDbNames.lua').open('w',encoding='utf-8',newline='\n') as f:
        f.write('-- Generated game_tele display names after Korean patch parsing.\nAzerothAdminMoP548 = AzerothAdminMoP548 or {}\nAzerothAdminMoP548.MoPTeleportDbNames = {\n')
        for e in sorted(tele_names):f.write(f'  [{e}]={esc_lua(tele_names[e])},\n')
        f.write('}\n')
    audit={'source_revision':'0739d072f8f1f42523f04cca4b2607d88a01def4','table_rows':dict(stats),'schemas':schemas,'quest_records':len(qdata),'objective_slots':objective_slots,'quest_starters':sum(len(v) for v in starters.values()),'quest_enders':sum(len(v) for v in enders.values()),'creature_spawn_entries':len(csp),'gameobject_spawn_entries':len(osp),'teleport_names':len(tele_names),'korean_teleport_names':sum(1 for n in tele_names.values() if re.search('[가-힣]',n))}
    (out/'audit.json').write_text(json.dumps(audit,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(audit,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
