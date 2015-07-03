<%@ page contentType="text/html; charset=GBK" language="java" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

    <meta http-equiv="Content-Type" content="text/html; charset=gb2312"/>
    <title>Naruto������</title>
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

    <h2 style="text-align: center">��ӭ����������~</h2>

    <div align="center">
        <form class="form-inline" role="form">
            <div class="form-group">
                <label class="sr-only" for="nickname">�����ǳ�</label>
                <input type="email" class="form-control" id="nickname" placeholder="�����ǳ�">
            </div>
            <button type="button" class="btn btn-default" onclick="register(this)" id="start_btn">��ʼ����</button>
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
                   style="width:230px;height:35px;font:menu;font-size: 16px;text-align: center" onclick="choice(this)">�����б�</a>
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
        <button type="button" class="btn btn-sm btn-primary" id="send" onclick="sendMsg()" disabled="disabled">������Ϣ
        </button>
        &nbsp;&nbsp;
        <span class="glyphicon glyphicon-hand-right"></span>
        <input class="form-contro" type="text" placeholder="ĳ�û�" readonly id="receiverName" value="">
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
     * ҳ���ʼ��
     */
    function init() {
        var nickname = getById('nickname');
        nickname.disabled = false;
        nickname.value = "";
        getById("start_btn").disabled = false;
        getById('message').disabled = true;
        getById('send').disabled = true;
        dwr.engine.setActiveReverseAjax(true); // ���ת ��Ҫ
        handler.updateUsersList(null, false); // ����򿪽����ʱ��,�Ȼ�������û��б�.
    }
    function offline() {
        handler.offline();
    }
    $(window).bind('load', init)//ҳ�������Ϻ�ִ�г�ʼ������init
    $(window).bind('beforeunload', offline)//�뿪ҳ��ʱ��������
    /**
     * ѡ���û�
     * */
    function choice(that) {
        getById("receiverId").value = that.value;
        getById("receiverName").value = that.text;
    }
    /**
     * ע���ǳ�
     */
    function register(button) {
        if (getById('nickname').value == "" || getById('nickname').value.length == 0) {
            alert("�������ǳ�");
            return;
        }
        /* ����������û���ע�ᵽ������,������û�id(������session id ����) */
        handler.updateUsersList(getById('nickname').value, true, function (data) {
            if (data != null) {
                var res = data.res;
                switch (res) {
                    case "success":
                        getById('userid').value = data.sessionId; // ע��ɹ�,��userid�ŵ���ǰҳ��
                        /* �����Ƕ�һЩ��ť�Ľ��úͼ������ */
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
     * ������Ϣ
     */
    function sendMsg() {
        var senderId = dwr.util.getValue("userId");
        var sender = dwr.util.getValue('nickname'); // ��÷���������
        var receiver = dwr.util.getValue('receiverId'); // ��ý�����id
        var receiverName = dwr.util.getValue("receiverName");//������name
        var msg = dwr.util.getValue('message'); // �����Ϣ����

        handler.send(senderId, sender, receiver, msg); // ������Ϣ
        var odiv = document.createElement("div");
        var op = document.createElement("p");
        odiv.className = "divr";

        if (receiver != "" && receiver != undefined && receiver != "undefined") {
            op.innerHTML = "���[" + receiverName + "]˵ :" + msg;
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
    *����û����ɺ�̨�ص���
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
    *���뿪��ҳ��ʱ�Ƴ����û����ɺ�̨�������û�ҳ��ִ�е��á�
     */
    function remove(data) {
        getById(data.sessionId).remove();
    }
    /**
     *������Ϣ���ɺ�̨�ص�
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
    *���������û��б��ɺ�̨�ص���
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
            users.removeChild(target);//ɾ�������ߵ��û���
        }
    }

</script>
</body>
</html>