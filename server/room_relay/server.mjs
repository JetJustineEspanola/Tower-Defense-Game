import { pathToFileURL } from 'node:url';
import http from 'node:http';
import { randomInt, randomUUID } from 'node:crypto';
import { WebSocketServer, WebSocket } from 'ws';
export const BUILD = 'codeborn-lobby-1';
const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const MAX_BYTES = 256 * 1024;
function validDeck(d) {
 if (!d || typeof d.name !== 'string' || !d.name.trim() || !Array.isArray(d.cards) || d.cards.length < 1 || d.cards.length > 500) return false;
 const types = ['multiple_choice', 'identification', 'code_fix'];
 if (!Array.isArray(d.enabled_types) || !d.enabled_types.length || d.enabled_types.some(t=>!types.includes(t))) return false;
 const ids = new Set(); let enabled = 0;
 for (const c of d.cards) {
  if (!c || typeof c.id !== 'string' || !c.id || ids.has(c.id) || !types.includes(c.type) || typeof c.prompt !== 'string' || !c.prompt.trim()) return false;
  ids.add(c.id); if (d.enabled_types.includes(c.type)) enabled++;
  if (!Number.isInteger(c.reward) || c.reward < 1 || c.reward > 1000) return false;
  for (const key of ['code','explanation']) if (c[key] !== undefined && typeof c[key] !== 'string') return false;
  if (c.type === 'multiple_choice') {
   if (!Array.isArray(c.choices) || c.choices.length !== 4 || c.choices.some(s=>typeof s!=='string'||!s.trim()) || new Set(c.choices.map(s=>s.trim().toLowerCase())).size !== 4 || !Number.isInteger(c.correct) || c.correct<0 || c.correct>3) return false;
  } else if (!Array.isArray(c.answers) || !c.answers.length || c.answers.some(s=>typeof s!=='string'||!s.trim())) return false;
 }
 return enabled > 0;
}
export function createRelay({port=Number(process.env.PORT||8080), host='0.0.0.0'}={}) {
 const rooms = new Map();
 const server = http.createServer((req,res)=>{
  res.writeHead(req.url==='/health'?200:404,{'Content-Type':'application/json'});
  res.end(JSON.stringify(req.url==='/health'?{status:'ok',build:BUILD}: {error:'not found'}));
 });
 const sockets = new WebSocketServer({server,path:'/rooms',maxPayload:MAX_BYTES,perMessageDeflate:false});
 const send=(s,m)=>{if(s.readyState===WebSocket.OPEN) s.send(JSON.stringify(m));};
 const fail=(s,message)=>send(s,{type:'error',message});
 const broadcast=r=>{
  const state={type:'room',code:r.code,host_id:r.host.id,deck:r.deck,deck_revision:r.revision,players:[r.host,r.guest].filter(Boolean).map(s=>({id:s.id,name:s.playerName,ready:s.ready,host:s===r.host}))};
  for(const s of [r.host,r.guest].filter(Boolean))send(s,state);
 };
 const leave=s=>{
  const r=rooms.get(s.roomCode);s.roomCode=null;s.ready=false;s.ack=0;
  if(!r)return;
  if(r.host===s){rooms.delete(r.code);if(r.guest){r.guest.roomCode=null;r.guest.ready=false;send(r.guest,{type:'room_closed',message:'The host left the room.'});}}
  else if(r.guest===s){r.guest=null;r.host.ready=false;broadcast(r);}
 };
 sockets.on('connection',s=>{
  if(sockets.clients.size>256){s.close(1013,'Server busy');return;}
  s.id=randomUUID();s.alive=true;s.hello=false;s.roomCode=null;s.ready=false;s.ack=0;s.window=Date.now();s.messages=0;
  s.on('pong',()=>s.alive=true);
  s.on('error',()=>{});
  s.on('close',()=>leave(s));
  s.on('message',(raw,binary)=>{
   if(binary){s.close(1003,'Text only');return;}
   if(Date.now()-s.window>1000){s.window=Date.now();s.messages=0;}
   if(++s.messages>15){s.close(1008,'Too many requests');return;}
   let m;try{m=JSON.parse(raw.toString());}catch{fail(s,'Invalid request.');return;}
   if(!m || typeof m!=='object' || Array.isArray(m)){fail(s,'Invalid request.');return;}
   if(m.type==='hello'){
    if(m.build!==BUILD){send(s,{type:'error',message:'Game versions do not match the relay.'});s.close(1008,'Version mismatch');return;}
    s.hello=true;send(s,{type:'hello',player_id:s.id});return;
   }
   if(!s.hello){fail(s,'Connect with a matching game version first.');return;}
   if(m.type==='leave'){leave(s);send(s,{type:'left'});return;}
   if(m.type==='create' || m.type==='join'){
    if(s.roomCode){fail(s,'Leave your current room first.');return;}
    s.playerName=typeof m.name==='string'?m.name.trim().slice(0,20):'';
    if(!s.playerName){fail(s,'Enter your player name.');return;}
    if(m.type==='create'){
     if(rooms.size>=100){fail(s,'Relay is full. Try again later.');return;}
     if(!validDeck(m.deck)){fail(s,'Choose a valid Astral deck before hosting.');return;}
     let code;do{code=Array.from({length:6},()=>alphabet[randomInt(alphabet.length)]).join('');}while(rooms.has(code));
     const r={code,host:s,guest:null,deck:{...m.deck,notes:[]},revision:1,created:Date.now()};rooms.set(code,r);s.roomCode=code;broadcast(r);
    } else {
     const code=String(m.code||'').replace(/[\s-]/g,'').toUpperCase();const r=rooms.get(code);
     if(!r){fail(s,'Room not found. Check the code with your friend.');return;}
     if(r.guest){fail(s,'This room already has two players.');return;}
     r.guest=s;s.roomCode=code;r.host.ready=false;broadcast(r);
    }return;
   }
   const r=rooms.get(s.roomCode);if(!r){fail(s,'Join a room first.');return;}
   if(m.type==='deck'){
    if(s!==r.host){fail(s,'Only the host can change the deck.');return;}
    if(!validDeck(m.deck)){fail(s,'Invalid question deck.');return;}
    r.deck={...m.deck,notes:[]};r.revision++;for(const member of [r.host,r.guest].filter(Boolean)){member.ready=false;member.ack=0;}broadcast(r);return;
   }
   if(m.type==='deck_ack'){
    if(m.revision===r.revision)s.ack=r.revision;return;
   }
   if(m.type==='ready'){
    if(m.revision!==r.revision || s.ack!==r.revision){fail(s,'Wait for the current deck to finish loading.');return;}
    s.ready=m.ready===true;broadcast(r);return;
   }
   // Combat is not synchronized yet. Never launch independent practice matches.
   if(m.type==='start'){fail(s,'Online combat is the next implementation step. This build supports room lobbies.');return;}
   fail(s,'Unknown request.');
  });
 });
 const heartbeat=setInterval(()=>{
  for(const s of sockets.clients){if(!s.alive)s.terminate();else{s.alive=false;s.ping();}}
  for(const r of rooms.values())if(!r.guest && Date.now()-r.created>30*60*1000){send(r.host,{type:'room_closed',message:'Unused room expired. Create a new room.'});leave(r.host);}
 },30000);heartbeat.unref();
 server.listen(port,host);
 return {server,sockets,rooms,close:async()=>{clearInterval(heartbeat);for(const s of sockets.clients)s.terminate();await new Promise(resolve=>sockets.close(resolve));await new Promise(resolve=>server.close(resolve));}};
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href){
 const relay=createRelay();console.log('CodeBorn room relay listening');
 for(const signal of ['SIGINT','SIGTERM'])process.on(signal,async()=>{await relay.close();process.exit(0);});
}
