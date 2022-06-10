create database if not exists sequels3;
use sequels3;
create user if not exists 'sequels3'@'%' identified by 'shugh5cah7At';
create table if not exists codes(
  cid char(36) primary key,
  qrdata varchar(4096));
create table if not exists flags(
  name varchar(32) primary key,
  value varchar(64));
insert ignore into flags(name, value) VALUES("flag", "CTF{hey_it_could_happen_qq}");
grant select, insert on sequels3.codes to 'sequels3'@'%';
grant select on sequels3.* to 'sequels3'@'%';
