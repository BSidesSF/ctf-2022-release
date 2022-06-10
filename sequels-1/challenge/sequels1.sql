create database if not exists sequels1;
use sequels1;
create user if not exists 'sequels1'@'%' identified by 'xohquief2Chu';
grant select on sequels1.* to 'sequels1'@'%';
create table if not exists jedi(
  name varchar(32) primary key,
  `type` varchar(32),
  planet varchar(32));
create table if not exists flags(
  name varchar(32) primary key,
  value varchar(64));
insert ignore into flags(name, value) VALUES("flag", "CTF{help_me_hacker_youre_my_only_hope}");
insert ignore into jedi(name, `type`, planet) VALUES
  ('Yoda', 'Jedi', 'Dagobah'),
  ('Luke Skywalker', 'Jedi', 'Tatooine'),
  ('Obi-Wan Kenobi', 'Jedi', 'Unknown'),
  ('Qui-Gon Jinn', 'Jedi', 'Unknown'),
  ('Mace Windu', 'Jedi', 'Unknown'),
  ('Rey Skywalker', 'Jedi', 'Jakku'),
  ('Darth Bane', 'Sith', 'Unknown'),
  ('Darth Sidious', 'Sith', 'Unknown'),
  ('Darth Maul', 'Sith', 'Unknown'),
  ('Darth Tyranus', 'Sith', 'Unknown'),
  ('Darth Vader', 'Sith', 'Unknown');
