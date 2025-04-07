# hr-dev-test-teyca

Решение тестового задания по вакансии в компанию TEYCA


Схема БД:

=== sqlite_sequence ===
0 | name |  | NOT NULL=0 | PK=0 | DEFAULT=None
1 | seq |  | NOT NULL=0 | PK=0 | DEFAULT=None

=== templates ===
0 | id | INTEGER | NOT NULL=1 | PK=1 | DEFAULT=None
1 | name | varchar(255) | NOT NULL=1 | PK=0 | DEFAULT=None
2 | discount | INT | NOT NULL=1 | PK=0 | DEFAULT=None
3 | cashback | INT | NOT NULL=1 | PK=0 | DEFAULT=None

=== users ===
0 | id | INTEGER | NOT NULL=1 | PK=1 | DEFAULT=None
1 | template_id | INT | NOT NULL=1 | PK=0 | DEFAULT=None
2 | name | varchar(255) | NOT NULL=1 | PK=0 | DEFAULT=None
3 | bonus | numeric | NOT NULL=0 | PK=0 | DEFAULT=None

=== products ===
0 | id | INTEGER | NOT NULL=1 | PK=1 | DEFAULT=None
1 | name | varchar(255) | NOT NULL=1 | PK=0 | DEFAULT=None
2 | type | varchar(255) | NOT NULL=0 | PK=0 | DEFAULT=None
3 | value | varchar(255) | NOT NULL=0 | PK=0 | DEFAULT=None

=== operations ===
0 | id | INTEGER | NOT NULL=1 | PK=1 | DEFAULT=None
1 | user_id | INT | NOT NULL=1 | PK=0 | DEFAULT=None
2 | cashback | numeric | NOT NULL=1 | PK=0 | DEFAULT=None
3 | cashback_percent | numeric | NOT NULL=1 | PK=0 | DEFAULT=None
4 | discount | numeric | NOT NULL=1 | PK=0 | DEFAULT=None
5 | discount_percent | numeric | NOT NULL=1 | PK=0 | DEFAULT=None
6 | write_off | numeric | NOT NULL=0 | PK=0 | DEFAULT=None
7 | check_summ | numeric | NOT NULL=1 | PK=0 | DEFAULT=None
8 | done | boolean | NOT NULL=0 | PK=0 | DEFAULT=None
9 | allowed_write_off | numeric | NOT NULL=0 | PK=0 | DEFAULT=None
Users: [(1, 1, 'Иван', 10000), (2, 2, 'Марина', 10000), (3, 3, 'Женя', 10000)]
sqlite_sequence: [('users', 3), ('templates', 4), ('products', 4), ('operations', 1)]
templates: [(1, 'Bronze', 0, 5), (2, 'Silver', 5, 5), (3, 'Gold', 15, 0)]
products: [(2, 'Молоко', 'increased_cashback', '10'), (3, 'Хлеб', 'discount', '15'), (4, 'Сахар', 'noloyalty', None)]
operations: []
