:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(http/http_cors)).
:- set_setting(http:cors, [*]).



:- http_handler(root(.), send_kafedras, []).
%:- http_handler(admin(send_kafedras), send_kafedras, []).
:- http_handler('/name', send_olimp, []).
:- http_handler('/type', send_sections, []).
:- json_object illnes(name:string).

:- initialization main.

send_olimp(Request) :-
    reply_options(Request, [get]),
    !.

send_olimp(_):-
    все_направления(Result),
    cors_enable,
    reply_json(json{answer:Result}).
	

send_kafedras(Request) :-
    reply_options(Request, [post]),
    !.

send_kafedras(Request) :-
        http_read_json(Request,Json,[json_object(term)]),
		все_кафедры_в_направлении(Json,Result),
        cors_enable,
        reply_json(json{answer:Result}).
		
send_sections(Request) :-
    reply_options(Request, [post]),
    !.
		
send_sections(Request) :-
        http_read_json(Request,Json,[json_object(term)]),
		раскрыть(Json, Направление, Кафедра),
		все_секции_в_кафедре(Направление, Кафедра, Список_секций),
        cors_enable,
        reply_json(json{answer:Список_секций}).

раскрыть([A,B],A,B).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

все_направления(Все_направления):-
	загрузить_БД('olimp.pl'),
	findall(X,(секция_в_направлении(_,X)),Список_направлений_повторы),
	уникальный_набор(Список_направлений_повторы, Все_направления).
	
	
%%%%%%%%%%%%%%%%% НАПРАВЛЕНИЕ-СЕКЦИИ-КАФЕДРА %%%%%%%%%%%%%%%%%
все_секции_в_направлении(Направление,Список_секций):-
	загрузить_БД('olimp.pl'),
	findall(X,(секция_в_направлении(X,Направление)),Список_секций).

все_кафедры_в_секции(Секция, Список_кафедр):-
	загрузить_БД('olimp.pl'),
	findall(X,(кафедра_в_секции(X, Секция)),Список_кафедр).
	
%%%%%%%%%%%%%%%%% НАПРАВЛЕНИЕ-КАФЕДРА-СЕКЦИЯ %%%%%%%%%%%%%%%%%
все_кафедры_в_направлении(Направление, Список_кафедр):-
	загрузить_БД('olimp.pl'),
	findall(X,(секция_в_направлении(Y,Направление),кафедра_в_секции(X,Y)),Список_кафедр_повторы),
	уникальный_набор(Список_кафедр_повторы, Список_кафедр).

все_секции_в_кафедре(Направление, Кафедра, Список_секций):-
	загрузить_БД('olimp.pl'),
	findall(X,(секция_в_направлении(X,Направление),кафедра_в_секции(Кафедра,X)),Список_секций_повторы),
	уникальный_набор(Список_секций_повторы, Список_секций).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
уникальный_набор(Список,Список_без_повторов):-
	уникальный_набор(Список,[],Список_без_повторов).

уникальный_набор([],Буфер,Буфер):-!.

уникальный_набор([H|T],Буфер, Результат):-
	not(есть(H,T)),!,
	уникальный_набор(T,[H|Буфер],Результат).
	
уникальный_набор([H|T],Буфер,Результат):-
	уникальный_набор(T,Буфер,Результат).






load_file:-
	загрузить_БД('sympt.pl'),
	загрузить_БД('bolezni.pl').
	
загрузить_файл:- load_file.

загрузить_файл(ИмяФайлаБолезней, ИмяФайлаСимптомов):-
	загрузить_БД(ИмяФайлаСимптомов),
	загрузить_БД(ИмяФайлаБолезней).

main():-
	%load_file,
	current_prolog_flag(argv, []),
	server(80),!.
	
main():-
	%load_file,
	current_prolog_flag(argv, [H|_]),
	atom_number(H,N),
	server(N),!.

send_menu(Request) :-
    reply_options(Request, [get]),
    !.

send_menu(_):-
    load_menu(Result),
    cors_enable,
    reply_json(json{answer:Result}).



% Приветствие сервера
% Отправка симптомов
hi(Request) :-
    reply_options(Request, [post]),
    !.

hi(Request) :-
        http_read_json(Request,Json,[json_object(term)]),
		загрузить_БД('Олимпиады.pl'),
		load_menu(Result),
        cors_enable,
        reply_json(json{answer:Result}).

		
reply_options(Request, Allowed) :-
    option(method(options), Request),
    !,
    cors_enable(Request,
                [ methods(Allowed)
                ]),
    format('Content-type: text/plain\r\n'),
    format('~n').


load_menu([Result1,Result2,Result3,Result4,Result5]):-
	загрузить_БД('olimp.pl'),
	findall([Name1, Kaf1],(шаг_космонавтика(Name1,Kaf1)),Result1),
	findall([Name2, Kaf2],(шаг_центр(Name2,Kaf2)),Result2),
	findall([Name3, Kaf3],(шаг_москва(Name3,Kaf3)),Result3),
	findall([Name4, Kaf4],(профессор_жуковский(Name4,Kaf4)),Result4),
	findall([Name5, Kaf5],(профессор_лебедев(Name5,Kaf5)),Result5).






server(Port) :-
        http_server(http_dispatch, [port(Port)]).



%загрузка БД из файла.
загрузить_БД(ИмяФайлаБД):-
        consult(ИмяФайлаБД).
		
		

%добавление болезни.
добавить_болезнь(_,[],_):- false.

добавить_болезнь(_,_,[]):- false.

добавить_болезнь(Болезнь,_,_):-
	болезнь(Болезнь,_,_), !, false.

добавить_болезнь(Болезнь,СписокСимптомов,Лекарства):-
		симптомы_из_списка(СписокСимптомов),
        assert(болезнь(Болезнь,СписокСимптомов,Лекарства)),
		выгрузить_БД.

		
%выгрузка БД в файл.
выгрузить_БД:-
        tell('bolezni.pl'),
        listing(болезнь),
        told,
		tell('sympt.pl'),
		listing(максимум),
		listing(симптом),
		told.

%Проверка на существование симптомов	
симптомы_из_списка([]).	
симптомы_из_списка([H|T]):-
	симптом(X,_),
	есть(H, [X]), симптомы_из_списка(T), !.
	

симптомы_из_списка([H|T]):-
	максимум(Max),
	NewMax is Max +1,
	assert(симптом(H, NewMax)),
	abolish(максимум/1),
	assert(максимум(NewMax)),
	симптомы_из_списка(T).

%удаление строки из БД.
удалить_из_БД(Болезнь):-
        retract(болезнь(Болезнь,_,_)),
		выгрузить_БД.

%Вычисление количества совпадений в 2-х списках
есть_хвост([],_,N,Ans):-Ans is N,!.
есть_хвост([H|T],List,N, Ans):- есть(H,List), NewN is N+1, есть_хвост(T,List,NewN,Ans),!.
есть_хвост([_|T],List,N, Ans):- есть_хвост(T,List, N, Ans),!.

%Есть ли этемент в списке
есть(_,[]):- false,!.
есть(X,[X|_]):- !.
есть(X,[_|T]):- есть(X,T), !.

количество_совпадений(List1,List2,N):-есть_хвост(List1,List2,0,N).

длина_списка_хвост([],L,N):-N is L,!.
длина_списка_хвост([_|T],L,N):- NewL is L+1,  длина_списка_хвост(T,NewL,N).

длина_списка(List,N):-длина_списка_хвост(List,0,N).

вычисли_процент(Совпадения, ДлинаСписка, Процент):-
    Процент is Совпадения*100/ДлинаСписка.

чем_я_болен(СимптомыПациента, Болезнь, Процент, Лекарства):-
    болезнь(Болезнь,СимптомыБолезни,Лекарства),
    количество_совпадений(СимптомыБолезни, СимптомыПациента, Совпадения),
    Совпадения > 0,
    длина_списка(СимптомыБолезни,ДлинаСписка),
    вычисли_процент(Совпадения, ДлинаСписка, Процент).

чем_я_болен(СимптомыПациента, Результат):-
    findall([Болезнь,Процент, Лекарства],(чем_я_болен(СимптомыПациента,Болезнь,Процент, Лекарства)),Результат).

цифры_в_симптомы(Список, Результат):-
	findall(X,(симптом(X,B),есть(B,Список)),Результат).
	

