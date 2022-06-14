create database if not exists sequels2;
use sequels2;
create user if not exists 'sequels2'@'%' identified by 'ohRies1jeequ';
create table if not exists files(
  fid char(64) primary key,
  filename varchar(255),
  remote_addr char(16),
  uploadts DATETIME DEFAULT CURRENT_TIMESTAMP,
  rawimg mediumblob
  );
create table if not exists exifs(
  fid char(64) not null,
  name varchar(128),
  value varchar(128),
  INDEX(fid),
  FOREIGN KEY (fid)
    REFERENCES files(fid)
    ON DELETE CASCADE,
  PRIMARY KEY(fid, name)
  );
create table if not exists flags(
  name varchar(32) primary key,
  value varchar(64));
insert ignore into flags(name, value) VALUES("flag", "CTF{its_encodings_all_the_way_down}");
grant select, insert, delete on sequels2.files to 'sequels2'@'%';
grant select, insert, delete on sequels2.exifs to 'sequels2'@'%';
grant select on sequels2.flags to 'sequels2'@'%';
