<%@ page contentType="text/html; charset=GBK" language="java" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

    <meta http-equiv="Content-Type" content="text/html; charset=gb2312"/>
    <title>Naruto聊天室</title>
    <link rel="Shortcut Icon" href="../images/wanhuatong.ico" type="image/x-icon"/>

    <link rel="stylesheet" href="http://cdn.bootcss.com/bootstrap/3.2.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="http://cdn.bootcss.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
    <script src="http://cdn.bootcss.com/jquery/1.11.1/jquery.min.js"></script>
    <script src="http://cdn.bootcss.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>

    <!--dwr-->
    <script type='text/javascript' src='/chatroom/dwr/engine.js'></script>
    <script type='text/javascript' src='/chatroom/dwr/interface/handler.js'></script>
    <script type='text/javascript' src='/chatroom/dwr/util.js'></script>



    <style>
        .con, .wraper {
            width: 900px;
            margin: 0 auto;
        }
        .con:after {
            content: '';
            display: block;
            overflow: hidden;
            clear: both;
        }
        .textarea {
            width: 600px;
            height: 450px;
            float: left;
            resize: none;
            margin-right: 10px;
            margin-bottom: 10px
        }
        .control {
            float: left;
            width: 220px;
            height: 450px;
        }
        .jumbotron {
            width: 600px;
            height: 60px;
            resize: none;
            display: block;
        }
        .p {
            display: inline-block;
            padding: 0 10px
        }
        .divl {
            text-align: left
        }
        .divr {
            text-align: right
        }
        /*.form-control{width: 600px;height: 60px;resize:none;display:block;}*/
        /*.btn-primary{margin: 10px 0 0 250px;position: relative;zoom:1;}*/
    </style>

</head>
<body>
<div>
    <p class="bg-primary">...</p>

    <h2 style="text-align: center">欢迎来到聊天室~</h2>

    <div align="center">
        <form class="form-inline" role="form">
            <div class="form-group">
                <label class="sr-only" for="nickname">输入昵称</label>
                <input type="email" class="form-control" id="nickname" placeholder="输入昵称">
            </div>
            <button type="button" class="btn btn-default" onclick="register(this)" id="start_btn">开始聊天</button>
        </form>
    </div>
</div>
<div class="wraper">
    <div class="con">
        <div class="textarea">
            <div class="jumbotron" style="width: 600px; height: 450px;resize:none;overflow:auto" name="content"
                 id="content">
            </div>
        </div>
        <div style="float:left;" class="control">
            <div class="list-group" style="width:230px;">
                <a href="javascript:void(0)" class="list-group-item list-group-item-success"
                   style="width:230px;height:35px;font:menu;font-size: 16px;text-align: center" onclick="choice(this)">在线列表</a>
            </div>
            <div>
                <select multiple class="form-control" style="width:230px;height:450px" id="users" name="users"
                        onclick="choice(this.options[this.selectedIndex])">
                </select>

            </div>
        </div>

    </div>
    <div style="" class="input-con">
        <textarea class="form-control" rows="3" style="width: 600px; height: 60px;" name="message"
                  id="message"></textarea>
        <button type="button" class="btn btn-sm btn-primary" id="send" onclick="sendMsg()" disabled="disabled">发送消息
        </button>
        &nbsp;&nbsp;
        <span class="glyphicon glyphicon-hand-right"></span>
        <input class="form-contro" type="text" placeholder="某用户" readonly id="receiverName" value="">
        <input type="hidden" id="receiverId" value="">
    </div>

</div>

<p class="bg-primary">...</p>


<input type="hidden" name="userid" id="userid"/>

<script language="javascript">

    function getByName(name) {
        return document.getElementsByName(name);
    }
    function getById(id) {
        return document.getElementById(id);
    }
    /**
     * 页面初始化
     */
    function init() {
        var nickname = getById('nickname');
        nickname.disabled = false;
        nickname.value = "";
        getById("start_btn").disabled = false;
        getById('message').disabled = true;
        getById('send').disabled = true;
        dwr.engine.setActiveReverseAjax(true); // 激活反转 重要
        handler.updateUsersList(null, false); // 当你打开界面的时候,先获得在线用户列表.
    }
    function offline() {
        handler.offline();
    }
    $(window).bind('load', init)//页面加载完毕后执行初始化方法init
    $(window).bind('beforeunload', offline)//离开页面时调用下线
    /**
     * 选择用户
     * */
    function choice(that) {
        getById("receiverId").value = that.value;
        getById("receiverName").value = that.text;
    }
    /**
     * 注册昵称
     */
    function register(button) {
        if (getById('nickname').value == "" || getById('nickname').value.length == 0) {
            alert("请输入昵称");
            return;
        }
        /* 把我输入的用户名注册到服务器,并获得用户id(这里用session id 代替) */
        handler.updateUsersList(getById('nickname').value, true, function (data) {
            if (data != null) {
                var res = data.res;
                switch (res) {
                    case "success":
                        getById('userid').value = data.sessionId; // 注册成功,把userid放到当前页面
                        /* 下面是对一些按钮的禁用和激活操作 */
                        getById('nickname').disabled = true;
                        button.disabled = true;
                        getById('message').disabled = false;
                        getById('send').disabled = false;
                        break;
                    case "fail":
                        alert(data.msg);
                        break;
                }
            }
        });
    }
    /**
     * 发送消息
     */
    function sendMsg() {
        var senderId = dwr.util.getValue("userId");
        var sender = dwr.util.getValue('nickname'); // 获得发送者名字
        var receiver = dwr.util.getValue('receiverId'); // 获得接受者id
        var receiverName = dwr.util.getValue("receiverName");//接收者name
        var msg = dwr.util.getValue('message'); // 获得消息内容

        handler.send(senderId, sender, receiver, msg); // 发送消息
        var odiv = document.createElement("div");
        var op = document.createElement("p");
        odiv.className = "divr";

        if (receiver != "" && receiver != undefined && receiver != "undefined") {
            op.innerHTML = "你对[" + receiverName + "]说 :" + msg;
            op.className = "bg-danger p";
        } else {
            op.innerHTML = "[" + sender + "] :" + msg;
            op.className = "bg-info p";
        }
        odiv.appendChild(op);
        getById("content").appendChild(odiv);
        getById("message").value = "";
    }
    /**
    *添加用户，由后台回调。
     */
    function append(data) {
        for (var i = 0; i < data.length; i++) {
            var option = document.createElement("option");
            option.className = "list-group-item list-group-item-info"
            option.style = "width:230px;height:35px"
            option.id = option.value = data[i].sessionId
            option.text = data[i].name
            getById("users").appendChild(option)
        }
    }
    /**
    *当离开此页面时移除此用户，由后台对所有用户页面执行调用。
     */
    function remove(data) {
        getById(data.sessionId).remove();
    }
    /**
     *接收消息，由后台回调
     */
    function receive(data) {
        var odiv = document.createElement("div");
        var op = document.createElement("p");

        odiv.className = "divl";
        op.innerHTML = "[" + data.sender + "]" + data.msg;
        op.className = data.isAlone ? "bg-danger p" : "bg-success p";

        odiv.appendChild(op);
        getById("content").appendChild(odiv);
    }
    /**
    *更新在线用户列表，由后台回调。
     */
    function updateUsers(data) {
        var users = getById("users"),
                target;
        for (var i in users.options) {
            if (options[i].value == data.scriptSessionId) {
                target = options[i];
            }
        }
        if (target) {
            users.removeChild(target);//删除已下线的用户。
        }
    }

</script>
</body>
</html>