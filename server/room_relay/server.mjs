import { pathToFileURL } from 'node:url';
import http from 'node:http';
import { randomInt, randomUUID } from 'node:crypto';
import { WebSocketServer, WebSocket } from 'ws';
export const BUILD = 'codeborn-match-1';
const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const MAX_BYTES = 512 * 1024;
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
function validCommand(action,d) {
 const integer=(key,min=0,max=1000000)=>Number.isSafeInteger(d[key]) && d[key]>=min && d[key]<=max;
 switch(action){
  case 'train': return integer('index',0,2);
  case 'place': return integer('pad',0,1000) && integer('index',0,2);
  case 'troop_upgrade': return integer('index',0,2) && integer('upgrade',0,4);
  case 'tower_upgrade': case 'tower_priority': return integer('id',1) && integer('index',0,4);
  case 'troop_priority': return integer('id',1) && integer('index',0,3);
  case 'troop_auto': return integer('id',1) && typeof d.value==='boolean';
  case 'siege': return integer('id',1);
  case 'boost': return integer('id');
  case 'guard': return integer('id',1) && Array.isArray(d.position) && d.position.length===3 && d.position.every(v=>typeof v==='number' && Number.isFinite(v) && Math.abs(v)<10000);
  case 'answer': return integer('token',1) && integer('choice',-1,3) && typeof d.answer==='string' && d.answer.length<=10000;
  case 'next_question': return integer('token',1);
  default: return false;
 }
}
export function createRelay({port=Number(process.env.PORT||8080), host='0.0.0.0'}={}) {
 const rooms = new Map();
 const server = http.createServer((req,res)=>{
  res.writeHead(req.url==='/health'?200:404,{'Content-Type':'application/json'});
  res.end(JSON.stringify(req.url==='/health'?{status:'ok',build:BUILD}: {error:'not found'}));
 });
 const sockets = new WebSocketServer({server,path:'/rooms',maxPayload:MAX_BYTES,perMessageDeflate:false});
 const send=(s,m)=>{if(s.readyState!==WebSocket.OPEN)return;if(s.bufferedAmount>2*1024*1024){s.close(1013,'Connection too slow');return;}s.send(JSON.stringify(m));};
 const fail=(s,message)=>send(s,{type:'error',message});
 const broadcast=r=>{
  const state={type:'room',code:r.code,host_id:r.host.id,deck:r.deck,deck_revision:r.revision,phase:r.phase,players:[r.host,r.guest].filter(Boolean).map(s=>({id:s.id,name:s.playerName,ready:s.ready,host:s===r.host}))};
  for(const s of [r.host,r.guest].filter(Boolean))send(s,state);
 };
 const begin=r=>{
  r.round++;r.matchId=randomUUID();r.seq=0;r.loaded.clear();r.votes.clear();r.phase='loading';r.loadingAt=Date.now();
  const hostRole=r.round===1?(randomInt(2)?'defender':'attacker'):(r.roles[r.host.id]==='defender'?'attacker':'defender');
  r.roles={[r.host.id]:hostRole,[r.guest.id]:hostRole==='defender'?'attacker':'defender'};
  for(const member of [r.host,r.guest])send(member,{type:'match_start',match_id:r.matchId,role:r.roles[member.id],host_role:hostRole,round:r.round,deck:r.deck});
 };
 const leave=s=>{
  const r=rooms.get(s.roomCode);s.roomCode=null;s.ready=false;s.ack=0;
  if(!r)return;
  if(r.host===s){rooms.delete(r.code);if(r.guest){r.guest.roomCode=null;r.guest.ready=false;send(r.guest,{type:'room_closed',message:'The host left the room.'});}}
  else if(r.guest===s){r.guest=null;r.host.ready=false;if(r.phase!=='lobby'){rooms.delete(r.code);r.host.roomCode=null;send(r.host,{type:'room_closed',message:'Your opponent disconnected. The match ended.'});}else broadcast(r);}
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
   if(++s.messages>80){s.close(1008,'Too many requests');return;}
   let m;try{m=JSON.parse(raw.toString());}catch{fail(s,'Invalid request.');return;}
   if(!m || typeof m!=='object' || Array.isArray(m)){fail(s,'Invalid request.');return;}
   if(m.type==='hello'){
    if(m.build!==BUILD){send(s,{type:'error',message:`Game and relay versions differ. Update both players and deploy relay ${m.build || BUILD}. Server is ${BUILD}.`});s.close(1008,'Version mismatch');return;}
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
     const r={code,host:s,guest:null,deck:{...m.deck,notes:[]},revision:1,created:Date.now(),phase:'lobby',round:0,roles:{},loaded:new Set(),votes:new Set(),seq:0,matchId:null};rooms.set(code,r);s.roomCode=code;broadcast(r);
    } else {
     const code=String(m.code||'').replace(/[\s-]/g,'').toUpperCase();const r=rooms.get(code);
     if(!r){fail(s,'Room not found. Check the code with your friend.');return;}
     if(r.phase!=='lobby'){fail(s,'This match has already started.');return;}
     if(r.guest){fail(s,'This room already has two players.');return;}
     r.guest=s;s.roomCode=code;r.host.ready=false;broadcast(r);
    }return;
   }
   const r=rooms.get(s.roomCode);if(!r){fail(s,'Join a room first.');return;}
   if(m.type==='deck'){
    if(s!==r.host){fail(s,'Only the host can change the deck.');return;}
    if(r.phase!=='lobby'){fail(s,'The deck is locked during a match.');return;}
    if(!validDeck(m.deck)){fail(s,'Invalid question deck.');return;}
    r.deck={...m.deck,notes:[]};r.revision++;for(const member of [r.host,r.guest].filter(Boolean)){member.ready=false;member.ack=0;}broadcast(r);return;
   }
   if(m.type==='deck_ack'){
    if(m.revision===r.revision)s.ack=r.revision;return;
   }
   if(m.type==='ready'){
    if(r.phase!=='lobby')return;
    if(m.revision!==r.revision || s.ack!==r.revision){fail(s,'Wait for the current deck to finish loading.');return;}
    s.ready=m.ready===true;broadcast(r);return;
   }
   if(m.type==='start'){
    if(s!==r.host || r.phase!=='lobby' || !r.guest || !r.host.ready || !r.guest.ready || r.host.ack!==r.revision || r.guest.ack!==r.revision){fail(s,'Both players must be ready with the same deck.');return;}
    begin(r);return;
   }
   if(m.type==='loaded'){
    if(r.phase!=='loading' || m.match_id!==r.matchId)return;
    r.loaded.add(s.id);
    if(r.loaded.size===2){r.phase='playing';for(const member of [r.host,r.guest])send(member,{type:'begin',match_id:r.matchId});}
    return;
   }
   if(m.type==='command'){
    if(r.phase!=='playing' || m.match_id!==r.matchId || typeof m.action!=='string' || !m.data || typeof m.data!=='object' || Array.isArray(m.data) || !Number.isSafeInteger(m.request_id))return;
    const permitted={defender:['place','tower_upgrade','tower_priority','guard','boost','answer','next_question'],attacker:['train','troop_upgrade','troop_priority','troop_auto','siege','boost','answer','next_question']};
    if(!permitted[r.roles[s.id]].includes(m.action)){fail(s,'This action belongs to the other role.');return;}
    if(!validCommand(m.action,m.data)){fail(s,'Invalid action data.');return;}
    if(Buffer.byteLength(JSON.stringify(m.data))>12000){fail(s,'Command is too large.');return;}
    send(r.host,{type:'command',match_id:r.matchId,player_id:s.id,role:r.roles[s.id],action:m.action,data:m.data,request_id:m.request_id});return;
   }
   if(m.type==='state'){
    if(s!==r.host || !['playing','result'].includes(r.phase) || m.match_id!==r.matchId || !Number.isSafeInteger(m.seq) || m.seq<=r.seq || !m.state || typeof m.state!=='object')return;
    r.seq=m.seq;send(r.guest,m);return;
   }
   if(m.type==='end'){
    if(s!==r.host || r.phase!=='playing' || m.match_id!==r.matchId || !['attacker','defender'].includes(m.winner))return;
    r.phase='result';r.votes.clear();for(const member of [r.host,r.guest])send(member,{type:'end',match_id:r.matchId,winner:m.winner});return;
   }
   if(m.type==='rematch'){
    if(r.phase!=='result' || !r.guest)return;
    r.votes.add(s.id);for(const member of [r.host,r.guest])send(member,{type:'rematch_wait',players:r.votes.size});
    if(r.votes.size===2)begin(r);return;
   }
   fail(s,'Unknown request.');
  });
 });
 const heartbeat=setInterval(()=>{
  for(const s of sockets.clients){if(!s.alive)s.terminate();else{s.alive=false;s.ping();}}
  for(const r of rooms.values())if(r.phase==='loading' && Date.now()-r.loadingAt>120000){send(r.host,{type:'room_closed',message:'Match loading timed out. Create a new room.'});leave(r.host);}
  for(const r of rooms.values())if(!r.guest && Date.now()-r.created>30*60*1000){send(r.host,{type:'room_closed',message:'Unused room expired. Create a new room.'});leave(r.host);}
 },30000);heartbeat.unref();
 server.listen(port,host);
 return {server,sockets,rooms,close:async()=>{clearInterval(heartbeat);for(const s of sockets.clients)s.terminate();await new Promise(resolve=>sockets.close(resolve));await new Promise(resolve=>server.close(resolve));}};
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href){
 const relay=createRelay();console.log('CodeBorn room relay listening');
 for(const signal of ['SIGINT','SIGTERM'])process.on(signal,async()=>{await relay.close();process.exit(0);});
}
