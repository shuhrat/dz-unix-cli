## Домашнее задание: [Unix Command Line](https://github.com/yandex-shri/lectures/blob/master/04-unix-cli.md)

Написать сценарий, который находит все файлы не входящие в SVN/Git и перемещает их в ~/.Trash/.

    git ls-files . --exclude-standard --others -z | xargs -0 -I {} mv {} ~/.Trash/

присылайте пулл реквесты с решением для SVN или с более элегантным подходом.

См. также: [пост про домашние задания](http://clubs.ya.ru/4611686018427468886/replies.xml?item_no=450).

shiroq
======

##Installation guide

* Clone project:
  `git clone https://github.com/Shuhrat/shiroq.git`

* Make a bin directory:
  `mkdir bin`

* Copy shiroq.sh to "bin":
  `cp shiroq.sh bin`
  
* Make shiroq.sh executable:
  `chmod u+x shiroq.sh`

* Add path to your `~/.bashrc` file

##Information
Shiroq is just a codename!
Project is created as an exersize, use on your own risk =)