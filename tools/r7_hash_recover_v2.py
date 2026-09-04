#!/usr/bin/env python3
from pathlib import Path
import hashlib, itertools, subprocess, sys

MANIFEST=Path(sys.argv[1])
OUT=Path(sys.argv[2])
REPOS=[Path(x) for x in sys.argv[3:]]
exp={}
for line in MANIFEST.read_text().splitlines():
    sha,path=line.split('\t',1); exp[path]=sha

def oid(data:bytes)->str:
    return hashlib.sha1(f'blob {len(data)}\0'.encode()+data).hexdigest()

def variants(data:bytes):
    yield data
    if b'\0' in data: return
    reps=[
        (b'AzerothAdminMoP',b'AzerothAdminMoP548'),
        (b'## Interface: 30300',b'## Interface: 50400'),
        (b'Interface: 30300',b'Interface: 50400'),
        (b'3.3.5a',b'5.4.8'),
        (b'335a',b'548'),
    ]
    seen={data}
    for mask in range(1,1<<len(reps)):
        x=data
        for i,(a,b) in enumerate(reps):
            if mask>>i & 1: x=x.replace(a,b)
        if x not in seen:
            seen.add(x); yield x

def accept(rel,data):
    want=exp.get(rel)
    if not want: return False
    for x in variants(data):
        if oid(x)==want:
            dst=OUT/rel.removeprefix('AzerothAdmin/')
            dst.parent.mkdir(parents=True,exist_ok=True)
            dst.write_bytes(x)
            print('RECOVERED',rel)
            return True
    return False

def valid(rel):
    p=OUT/rel.removeprefix('AzerothAdmin/')
    return p.is_file() and oid(p.read_bytes())==exp[rel]

# Remove wrong files first.
for rel in exp:
    p=OUT/rel.removeprefix('AzerothAdmin/')
    if p.is_file() and not valid(rel): p.unlink()

# Exact Git objects are universal across repositories.
for rel,want in exp.items():
    if valid(rel): continue
    for repo in REPOS:
        r=subprocess.run(['git','-C',str(repo),'cat-file','-e',want+'^{blob}'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        if r.returncode==0:
            data=subprocess.check_output(['git','-C',str(repo),'cat-file','blob',want])
            if accept(rel,data): break

# Same-path history is the strongest transformed candidate source.
for rel in exp:
    if valid(rel): continue
    for repo in REPOS:
        path=rel
        commits=subprocess.run(['git','-C',str(repo),'log','--all','--format=%H','--',path],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True).stdout.splitlines()
        for c in commits[:300]:
            r=subprocess.run(['git','-C',str(repo),'show',f'{c}:{path}'],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL)
            if r.returncode==0 and accept(rel,r.stdout): break
        if valid(rel): break

# Last resort: scan historical blobs and accept only exact target OIDs after deterministic transforms.
missing={sha:rel for rel,sha in exp.items() if not valid(rel)}
if missing:
    for repo in REPOS:
        lines=subprocess.run(['git','-C',str(repo),'rev-list','--objects','--all'],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True).stdout.splitlines()
        seen=set()
        for line in lines:
            sha=line.split(' ',1)[0]
            if sha in seen: continue
            seen.add(sha)
            t=subprocess.run(['git','-C',str(repo),'cat-file','-t',sha],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True)
            if t.returncode or t.stdout.strip()!='blob': continue
            sz=subprocess.run(['git','-C',str(repo),'cat-file','-s',sha],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True)
            if sz.returncode or int(sz.stdout.strip() or 0)>2_500_000: continue
            data=subprocess.check_output(['git','-C',str(repo),'cat-file','blob',sha])
            for x in variants(data):
                h=oid(x)
                rel=missing.get(h)
                if rel:
                    dst=OUT/rel.removeprefix('AzerothAdmin/')
                    dst.parent.mkdir(parents=True,exist_ok=True); dst.write_bytes(x)
                    print('RECOVERED_SCAN',rel)
                    missing.pop(h,None)
                    if not missing: break
            if not missing: break
        if not missing: break

bad=[rel for rel in exp if not valid(rel)]
print('remaining',len(bad))
for rel in bad: print('MISSING',rel,exp[rel])
sys.exit(0 if not bad else 2)
