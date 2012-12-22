#!/bin/sh

#
# My "manage.py" wrapper.
#
# @usage djmanage <ACTION> [<ARG1> <ARG2> ..]
#
# Todos:
# - 引数整理、getoptでオプション化
# - virtualenv時に$PATHをいじってこのコマンドが有る場所を優先的に読むようにする
# - MySQL対応
# - 本番利用にも耐えれるように
# - 実行した実コマンドを出力させたかったけど、コマンド全部を文字列にするとちゃんと実行できず
#   bashクックブックを読んで出直し
# - dumpdataなどの標準出力を使うコマンドときに前後の出力制御をしないといけないが
#   それが今は適当
#

#------------------------
# Environments
#------------------------
PYTHON_CMD='python'
PROJECT_DIR=/path/to/project_name
MANAGEPY_REL_FILE_PATH=app/manage.py
SETTINGS_OPT='--settings=settings.yourname'
DB_NAME='db_name'


#------------------------
# Computed variables
#------------------------
MANAGEPY_FILE_PATH=$PROJECT_DIR/$MANAGEPY_REL_FILE_PATH
MANAGEPY_CMD="$PYTHON_CMD $MANAGEPY_FILE_PATH"
SQLITE_FILE_PATH=$PROJECT_DIR/$DB_NAME.sqlite

ACTION=$1
#SITE_DIR='__not_use__'
#if [ "$2" != "" ]; then
#    SITE_DIR=$2
#fi


#------------------------
# Functions
#------------------------
syncdb ()
{
    expect -c "
        spawn $MANAGEPY_CMD syncdb $SETTINGS_OPT
        expect \"Would you like to create one now\" {
            send \"yes\n\"
        }
        expect \"Username\" {
            send \"admin\n\"
        }
        expect \"E-mail address\" {
            send \"admin@email.address\n\"
        }
        expect \"Password\" {
            send \"test\n\"
        }
        expect \"Password \\(again\\)\" {
            send \"test\n\"
        }
        interact
    "
}
purgedb ()
{
    if [ ! -f $SQLITE_FILE_PATH ]; then
        echo 'Not exist database'
        exit 1
    fi
    rm $SQLITE_FILE_PATH
    # 本来こちらを使うべきだが、途中でプロンプトが数回出るので後で対応
    #$MANAGEPY_CMD reset $SETTINGS_OPT core
}
#init ()
#{
#    syncdb
#    #$PYTHON_CMD ./gs/manage.py syncdb
#    #$PYTHON_CMD ./gs/_initial_data.py
#    #mkdir -m 0777 -p _media/data/uploaded_file
#}


#------------------------
# Processing
#------------------------
if [ ! "$ACTION" = "dumpdata" ]; then
    echo "Start '$ACTION' action."
fi

if [ "$ACTION" = "init" ]; then
    echo 'Not implemented'
elif [ "$ACTION" = "reinit" ]; then
    echo 'Not implemented'
elif [ "$ACTION" = "syncdb" ]; then
    syncdb
elif [ "$ACTION" = "purgedb" ]; then
    purgedb
elif [ "$ACTION" = "resetdb" ]; then
    purgedb
    syncdb
elif [ "$ACTION" = "dumpdata" ]; then
    APP_NAME='core'
    if [ "$2" != "" ]; then
        APP_NAME=$2
    fi
    $MANAGEPY_CMD dumpdata --format=json $SETTINGS_OPT $APP_NAME | $PYTHON_CMD -mjson.tool
elif [ "$ACTION" = "runserver" ]; then
    RUNSERVER_PORT='8000'
    if [ "$2" != "" ]; then
        RUNSERVER_PORT=$2
    fi
    $MANAGEPY_CMD runserver 127.0.0.1:$RUNSERVER_PORT $SETTINGS_OPT
elif [ "$ACTION" = "cleanup" ]; then
    $MANAGEPY_CMD cleanup $SETTINGS_OPT
elif [ "$ACTION" = "cleanpyc" ]; then
    find $PROJECT_DIR -type f -name '*.pyc' | xargs --no-run-if-empty rm -rv
elif [ "$ACTION" = "chmodall" ]; then
    echo 'Not implemented'
    #chmod 0777 ./
    #chmod 0777 _apps
    #chmod 0777 _media/data/uploaded_file
    #chmod 0777 _tmp
elif [ "$ACTION" = "shell" ]; then
    $MANAGEPY_CMD shell $SETTINGS_OPT
elif [ "$ACTION" = "test" ]; then
    TARGET='core'
    if [ "$2" != "" ]; then
        TARGET=$2
    fi
    $MANAGEPY_CMD test $TARGET $SETTINGS_OPT
else
    echo "Error: This is invalid parameter."
    exit 1
fi

$CMD

if [ ! "$ACTION" = "dumpdata" ]; then
    echo "Complete '$ACTION' action."
fi
