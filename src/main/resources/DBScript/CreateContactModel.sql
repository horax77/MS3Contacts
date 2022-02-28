drop table ContactAdress;
drop table ContactCommunicationChannel;
drop table CommunicationChannelType;
drop table State;
drop table AdressType;
drop table Contact;

create table Contact (
    Id int NOT NULL  IDENTITY(1,1) primary key,
    LastName varchar(255) NOT NULL,
    FirstName varchar(255) NOT NULL,
	Gender varchar(1) not null,
    DOB date not null,
	Title varchar(255) not null,
	CorrelationId varchar(255) not null, --for traceability purpose
	PPN_DT datetime not null  default getdate(),
	   CONSTRAINT UNQ_Contact UNIQUE(LastName, FirstName, DOB)   
);

create table AdressType (
Id int NOT NULL primary key ,
Description varchar(255));

insert into AdressType (id, Description) values (1,'Home');
insert into AdressType (id, Description) values (2,'Work');
insert into AdressType (id, Description) values (3,'Alternative');

create table State (
id int not null primary key,
Description varchar(255) not null, 
); 

insert into state (id, description) values (1,'Alabama');
insert into state (id, description) values (2,'Alaska');
insert into state (id, description) values (3,'Arizona');
insert into state (id, description) values (4,'Arkansas');
insert into state (id, description) values (5,'California');
insert into state (id, description) values (6,'North Carolina');
insert into state (id, description) values (7,'South Carolina ');
insert into state (id, description) values (8,'Colorado');
insert into state (id, description) values (9,'Connecticut');
insert into state (id, description) values (10,'North Dakota');
insert into state (id, description) values (11,'Sounth Dakota');
insert into state (id, description) values (12,'Delaware');
insert into state (id, description) values (13,'Florida');
insert into state (id, description) values (14,'Georgia');
insert into state (id, description) values (15,'Hawai');
insert into state (id, description) values (16,'Idaho');
insert into state (id, description) values (17,'Illinois');
insert into state (id, description) values (18,'Indiana');
insert into state (id, description) values (19,'Iowa');
insert into state (id, description) values (20,'Kansas');
insert into state (id, description) values (21,'Kentucky');
insert into state (id, description) values (22,'Luisiana');
insert into state (id, description) values (23,'Maine');
insert into state (id, description) values (24,'Maryland');
insert into state (id, description) values (25,'Massachusetts');
insert into state (id, description) values (26,'Míchigan');
insert into state (id, description) values (27,'Minnesota');
insert into state (id, description) values (28,'Misisipi');
insert into state (id, description) values (29,'Misuri');
insert into state (id, description) values (30,'Montana');
insert into state (id, description) values (31,'Nebraska');
insert into state (id, description) values (32,'Nevada');
insert into state (id, description) values (33,'New Jersey');
insert into state (id, description) values (34,'New York');
insert into state (id, description) values (35,'New Hampshire');​
insert into state (id, description) values (36,'New México');
insert into state (id, description) values (37,'Ohio');
insert into state (id, description) values (38,'Oklahoma');
insert into state (id, description) values (39,'Oregón');
insert into state (id, description) values (40,'Pensilvania');
insert into state (id, description) values (41,'Rhode Island');
insert into state (id, description) values (42,'Tennessee');
insert into state (id, description) values (43,'Texas');
insert into state (id, description) values (44,'Utah');
insert into state (id, description) values (45,'Vermont');
insert into state (id, description) values (46,'Virginia');
insert into state (id, description) values (47,'West Virginia');
insert into state (id, description) values (48,'Washington');
insert into state (id, description) values (49,'Wisconsin');
insert into state (id, description) values (50,'Wyoming');


create table ContactAdress (
	Id int NOT NULL IDENTITY(1,1) primary key ,
	ContactId int not null ,
			CONSTRAINT FK_ConctactId FOREIGN KEY (ContactId)
        REFERENCES Contact (Id),
	TypeId int not null 
	CONSTRAINT FK_AddressType FOREIGN KEY (TypeId)
        REFERENCES AdressType (Id),
	Street varchar(255) not null,
	StreetNumber varchar(10) not null,
	Unit varchar(100) null,
	City varchar(100) not null,
	StateId int not null,
		CONSTRAINT FK_State FOREIGN KEY (StateId)
        REFERENCES State (Id),
    ZipCode varchar(20) null,
	CorrelationId varchar(255) not null, --Population correlationId
	PPN_DT datetime not null  default getdate(), --Population DateTime
	CONSTRAINT UNQ_Address UNIQUE(ContactId, TypeId, Street, StreetNumber, City, StateId)
	);

create table CommunicationChannelType (
Id int not null primary key ,
Description varchar(255));

insert into CommunicationChannelType (id, Description) values (1,'Email');
insert into CommunicationChannelType (id, Description) values (2,'Phone');
insert into CommunicationChannelType (id, Description) values (3,'Other');

create table ContactCommunicationChannel (
	Id int not null  IDENTITY(1,1) primary key ,
	ContactId int not null ,
		CONSTRAINT FK_Communication_ConctactId FOREIGN KEY (ContactId)
        REFERENCES Contact (Id),	
	TypeId  int not null ,
		CONSTRAINT FK_CommunicationChannelType FOREIGN KEY (TypeId)
        REFERENCES CommunicationChannelType (Id),
	Value varchar(255) not null,
	PreferredFlg BIT not null default 0,
	CorrelationId varchar(255) not null,
	PPN_DT datetime not null  default getdate()
	CONSTRAINT UNQ_Communication UNIQUE(ContactId, TypeId, Value)
	);
	

