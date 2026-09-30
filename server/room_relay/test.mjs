import test from 'node:test';
import assert from 'node:assert/strict';
import { once } from 'node:events';
import { WebSocket } from 'ws';
import { createRelay, BUILD } from './server.mjs';
const deck={name:'Web development',enabled_types:['identification'],cards:[{id:'one',type:'identification',prompt:'What does HTML stand for?',answers:['Hypertext Markup Language'],reward:25}],notes:[]};
async function client(url){
 const s=new WebSocket(url);let queue=[],waiters=[];
 s.on('message',raw=>{const m=JSON.parse(raw);const w=waiters.shift();if(w)w(m);else queue.push(m);});
 await once(s,'open');
 const send=m=>s.send(JSON.stringify(m));
 const next=()=>queue.length?Promise.resolve(queue.shift()):Promise.race([new Promise(resolve=>waiters.push(resolve)),new Promise((_,reject)=>setTimeout(()=>reject(Error('message timeout')),2000).unref())]);
 send({type:'hello',build:BUILD});const hello=await next();assert.equal(hello.type,'hello');
 return {s,send,next,id:hello.player_id};
}
test('room codes, limits, deck authority, ready invalidation and disconnects',async()=>{
 const r=createRelay({port:0,host:'127.0.0.1'});await once(r.server,'listening');
 const url=`ws://127.0.0.1:${r.server.address().port}/rooms`;
 try{
  const h=await client(url),g=await client(url),third=await client(url);
  h.send({type:'create',name:'Jet',deck});let room=await h.next();assert.match(room.code,/^[A-Z2-9]{6}$/);const code=room.code;
  g.send({type:'join',name:'Ronel',code});room=await g.next();await h.next();assert.equal(room.players.length,2);
  third.send({type:'join',name:'Third',code});assert.equal((await third.next()).type,'error');
  g.send({type:'deck',deck});assert.match((await g.next()).message,/Only the host/);
  h.send({type:'deck_ack',revision:1});g.send({type:'deck_ack',revision:1});
  g.send({type:'ready',ready:true,revision:1});assert.equal((await g.next()).players[1].ready,true);await h.next();
  h.send({type:'deck',deck:{...deck,name:'Updated'}});room=await h.next();await g.next();assert.equal(room.deck_revision,2);assert.equal(room.players[1].ready,false);
  g.send({type:'ready',ready:true,revision:1});assert.equal((await g.next()).type,'error');
  h.send({type:'leave'});assert.equal((await g.next()).type,'room_closed');assert.equal((await h.next()).type,'left');assert.equal(r.rooms.size,0);
  h.s.close();g.s.close();third.s.close();
 }finally{await r.close();}
});

test('match authority, role commands, loading, results and role-swapping rematch',async()=>{
 const r=createRelay({port:0,host:'127.0.0.1'});await once(r.server,'listening');
 const url=`ws://127.0.0.1:${r.server.address().port}/rooms`;
 try{
  const h=await client(url),g=await client(url);
  h.send({type:'create',name:'Host',deck});const room=await h.next();
  g.send({type:'join',name:'Guest',code:room.code});await g.next();await h.next();
  h.send({type:'start'});assert.equal((await h.next()).type,'error');
  for(const c of [h,g])c.send({type:'deck_ack',revision:1});
  h.send({type:'ready',ready:true,revision:1});await h.next();await g.next();
  g.send({type:'ready',ready:true,revision:1});await h.next();await g.next();
  g.send({type:'start'});assert.equal((await g.next()).type,'error');
  h.send({type:'start'});const hm=await h.next(),gm=await g.next();
  assert.equal(hm.type,'match_start');assert.notEqual(hm.role,gm.role);assert.equal(hm.match_id,gm.match_id);
  const mid=hm.match_id;
  h.send({type:'loaded',match_id:mid});
  await new Promise(resolve=>setTimeout(resolve,30));assert.equal(r.rooms.get(room.code).phase,'loading');
  g.send({type:'loaded',match_id:mid});assert.equal((await h.next()).type,'begin');await g.next();
  g.send({type:'deck',deck});assert.equal((await g.next()).type,'error');
  const attacker=hm.role==='attacker'?h:g, defender=attacker===h?g:h;
  defender.send({type:'command',match_id:mid,request_id:1,action:'train',data:{index:0}});assert.equal((await defender.next()).type,'error');
  attacker.send({type:'command',match_id:mid,request_id:1,action:'train',data:{index:'bad'}});assert.equal((await attacker.next()).type,'error');
  attacker.send({type:'command',match_id:mid,request_id:2,action:'train',data:{index:0},role:'defender',player_id:'fake'});
  const command=await h.next();assert.equal(command.role,'attacker');assert.equal(command.player_id,attacker.id);
  g.send({type:'state',match_id:mid,seq:900,state:{forged:true}});
  g.send({type:'end',match_id:mid,winner:'attacker'});
  await new Promise(resolve=>setTimeout(resolve,30));assert.equal(r.rooms.get(room.code).phase,'playing');assert.equal(r.rooms.get(room.code).seq,0);
  h.send({type:'state',match_id:mid,seq:1,state:{health:80}});assert.equal((await g.next()).state.health,80);
  h.send({type:'state',match_id:mid,seq:1,state:{health:90}});
  h.send({type:'end',match_id:mid,winner:'defender'});assert.equal((await h.next()).winner,'defender');assert.equal((await g.next()).winner,'defender');
  h.send({type:'rematch'});assert.equal((await h.next()).players,1);await g.next();
  g.send({type:'rematch'});await h.next();await g.next();
  const hm2=await h.next(),gm2=await g.next();assert.equal(hm2.role,gm.role);assert.equal(gm2.role,hm.role);assert.notEqual(hm2.match_id,mid);
  g.send({type:'leave'});assert.equal((await h.next()).type,'room_closed');await g.next();assert.equal(r.rooms.size,0);
  h.s.close();g.s.close();
 }finally{await r.close();}
});
