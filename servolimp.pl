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
    ���_�����������(Result),
    cors_enable,
    reply_json(json{answer:Result}).
	

send_kafedras(Request) :-
    reply_options(Request, [post]),
    !.

send_kafedras(Request) :-
        http_read_json(Request,Json,[json_object(term)]),
		���_�������_�_�����������(Json,Result),
        cors_enable,
        reply_json(json{answer:Result}).
		
send_sections(Request) :-
    reply_options(Request, [post]),
    !.
		
send_sections(Request) :-
        http_read_json(Request,Json,[json_object(term)]),
		��������(Json, �����������, �������),
		���_������_�_�������(�����������, �������, ������_������),
        cors_enable,
        reply_json(json{answer:������_������}).

��������([A,B],A,B).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

���_�����������(���_�����������):-
	���������_��('olimp.pl'),
	findall(X,(������_�_�����������(_,X)),������_�����������_�������),
	����������_�����(������_�����������_�������, ���_�����������).
	
	
%%%%%%%%%%%%%%%%% �����������-������-������� %%%%%%%%%%%%%%%%%
���_������_�_�����������(�����������,������_������):-
	���������_��('olimp.pl'),
	findall(X,(������_�_�����������(X,�����������)),������_������).

���_�������_�_������(������, ������_������):-
	���������_��('olimp.pl'),
	findall(X,(�������_�_������(X, ������)),������_������).
	
%%%%%%%%%%%%%%%%% �����������-�������-������ %%%%%%%%%%%%%%%%%
���_�������_�_�����������(�����������, ������_������):-
	���������_��('olimp.pl'),
	findall(X,(������_�_�����������(Y,�����������),�������_�_������(X,Y)),������_������_�������),
	����������_�����(������_������_�������, ������_������).

���_������_�_�������(�����������, �������, ������_������):-
	���������_��('olimp.pl'),
	findall(X,(������_�_�����������(X,�����������),�������_�_������(�������,X)),������_������_�������),
	����������_�����(������_������_�������, ������_������).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
����������_�����(������,������_���_��������):-
	����������_�����(������,[],������_���_��������).

����������_�����([],�����,�����):-!.

����������_�����([H|T],�����, ���������):-
	not(����(H,T)),!,
	����������_�����(T,[H|�����],���������).
	
����������_�����([H|T],�����,���������):-
	����������_�����(T,�����,���������).






load_file:-
	���������_��('sympt.pl'),
	���������_��('bolezni.pl').
	
���������_����:- load_file.

���������_����(����������������, �����������������):-
	���������_��(�����������������),
	���������_��(����������������).

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



% ����������� �������
% �������� ���������
hi(Request) :-
    reply_options(Request, [post]),
    !.

hi(Request) :-
        http_read_json(Request,Json,[json_object(term)]),
		���������_��('���������.pl'),
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
	���������_��('olimp.pl'),
	findall([Name1, Kaf1],(���_������������(Name1,Kaf1)),Result1),
	findall([Name2, Kaf2],(���_�����(Name2,Kaf2)),Result2),
	findall([Name3, Kaf3],(���_������(Name3,Kaf3)),Result3),
	findall([Name4, Kaf4],(���������_���������(Name4,Kaf4)),Result4),
	findall([Name5, Kaf5],(���������_�������(Name5,Kaf5)),Result5).






server(Port) :-
        http_server(http_dispatch, [port(Port)]).



%�������� �� �� �����.
���������_��(����������):-
        consult(����������).
		
		

%���������� �������.
��������_�������(_,[],_):- false.

��������_�������(_,_,[]):- false.

��������_�������(�������,_,_):-
	�������(�������,_,_), !, false.

��������_�������(�������,���������������,���������):-
		��������_��_������(���������������),
        assert(�������(�������,���������������,���������)),
		���������_��.

		
%�������� �� � ����.
���������_��:-
        tell('bolezni.pl'),
        listing(�������),
        told,
		tell('sympt.pl'),
		listing(��������),
		listing(�������),
		told.

%�������� �� ������������� ���������	
��������_��_������([]).	
��������_��_������([H|T]):-
	�������(X,_),
	����(H, [X]), ��������_��_������(T), !.
	

��������_��_������([H|T]):-
	��������(Max),
	NewMax is Max +1,
	assert(�������(H, NewMax)),
	abolish(��������/1),
	assert(��������(NewMax)),
	��������_��_������(T).

%�������� ������ �� ��.
�������_��_��(�������):-
        retract(�������(�������,_,_)),
		���������_��.

%���������� ���������� ���������� � 2-� �������
����_�����([],_,N,Ans):-Ans is N,!.
����_�����([H|T],List,N, Ans):- ����(H,List), NewN is N+1, ����_�����(T,List,NewN,Ans),!.
����_�����([_|T],List,N, Ans):- ����_�����(T,List, N, Ans),!.

%���� �� ������� � ������
����(_,[]):- false,!.
����(X,[X|_]):- !.
����(X,[_|T]):- ����(X,T), !.

����������_����������(List1,List2,N):-����_�����(List1,List2,0,N).

�����_������_�����([],L,N):-N is L,!.
�����_������_�����([_|T],L,N):- NewL is L+1,  �����_������_�����(T,NewL,N).

�����_������(List,N):-�����_������_�����(List,0,N).

�������_�������(����������, �����������, �������):-
    ������� is ����������*100/�����������.

���_�_�����(����������������, �������, �������, ���������):-
    �������(�������,���������������,���������),
    ����������_����������(���������������, ����������������, ����������),
    ���������� > 0,
    �����_������(���������������,�����������),
    �������_�������(����������, �����������, �������).

���_�_�����(����������������, ���������):-
    findall([�������,�������, ���������],(���_�_�����(����������������,�������,�������, ���������)),���������).

�����_�_��������(������, ���������):-
	findall(X,(�������(X,B),����(B,������)),���������).
	

