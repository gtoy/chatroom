package cn.pconline.chatroom;


import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.directwebremoting.Browser;
import org.directwebremoting.ScriptBuffer;
import org.directwebremoting.ScriptSession;
import org.directwebremoting.ServerContext;
import org.directwebremoting.ServerContextFactory;
import org.directwebremoting.WebContextFactory;
import org.directwebremoting.event.ScriptSessionListener;
import org.directwebremoting.extend.ScriptSessionManager;
import org.directwebremoting.ui.dwr.Util;


/**
 * 处理聊天相关
 *
 * @author gxl
 */
public class Handler {

    /**
     * 保存当前在线用户列表
     */
    public static List<UserBean> users = new ArrayList<UserBean>();
    private static ScriptSessionListener listener = new MyScriptSessionListener();
    public static final String CHAT_PAGE_PATH = "/chatroom/chat.jsp";

    static {
        ServerContextFactory.get().getContainer().getBean(ScriptSessionManager.class).addScriptSessionListener(listener);
    }

    /**
     * 更新在线用户列表
     *
     * @param username 待添加到列表的用户名
     * @param flag     是添加用户到列表,还是只获得当前列表
     * @param request
     * @return 用户userid
     */
    public static JSONObject updateUsersList(String username, boolean flag, HttpServletRequest request) {
        UserBean user = null;
        JSONObject result = new JSONObject();
        if (flag) {
            for (UserBean userBean : users) {
                if (userBean.getName().equals(username)) {
                    result.element("res", "fail");
                    result.element("msg", "该昵称已被占用，请换一个昵称~");
                    return result;
                }
            }
            user = new UserBean(username, WebContextFactory.get().getScriptSession().getId());
            users.add(user);
        }

        ServerContext sctx = WebContextFactory.get();
        Browser.withAllSessions(sctx, new Runnable() {

            @SuppressWarnings({"unchecked", "static-access"})
            public void run() {
                Util.removeAllOptions("users");//移除页面id为users的select元素下所有option，即用户列表

                Collection<ScriptSession> sessions = getScriptSessionsByPage(CHAT_PAGE_PATH);//获取当前所有打开chat.jsp页面的链接session

                List remove = new ArrayList();
                boolean f = false;
                for (UserBean user : users) {
                    for (ScriptSession session : sessions) {
                        if (user.getSessionId().equals(session.getId())) {//判断当前在线列表中的user是否已下线
                            f = true;
                            break;
                        }
                    }
                    if (!f) {
                        remove.add(user);
                    }
                }
                users.removeAll(remove);//删除已过期的user

                for (ScriptSession scriptsession : sessions) {
                    //更新所有页面的用户列表
                    scriptsession.addScript(new ScriptBuffer().appendCall("append", JSONArray.fromObject(users)));
                }
            }
        });
        if (!flag) {
            return null;
        }
        JSONObject omsg = new JSONObject();

        omsg.element("sender", "系统消息");
        omsg.element("msg", "：欢迎来到聊天室！,点击某用户此消息单独发给此用户，点击在线列表此消息将发给所有人！");
        WebContextFactory.get().getScriptSession().addScript(new ScriptBuffer().appendCall("receive", omsg));
        result.element("res", "success");
        result.element("sessionId", user.getSessionId());
        return result;
    }

    /**
     * 用户下线。由前台用户离开页面时触发事件调用
     */
    public void offline() {
        String ScriptSessionId = WebContextFactory.get().getScriptSession().getId();

        System.out.println("run  offline:>>" + ScriptSessionId);
        UserBean offlineUser = null;
        for (final UserBean userBean : users) {
            if (userBean.getSessionId().equals(ScriptSessionId)) {
                System.out.println(userBean.getName() + ":>>下线" + userBean.getSessionId());
                Browser.withAllSessions(WebContextFactory.get(), new Runnable() {

                    @SuppressWarnings("deprecation")
                    public void run() {
                        Collection<ScriptSession> sessions = WebContextFactory.get().getScriptSessionsByPage(CHAT_PAGE_PATH);
                        JSONObject omsg = new JSONObject();

                        omsg.element("sender", "系统消息");
                        omsg.element("msg", "：[" + userBean.getName() + "]已下线！");
                        omsg.element("isAlone", false);
                        for (ScriptSession scriptsession : sessions) {
                            //对所有页面，回调页面发送消息函数，并将信息传递，回调页面移除用户函数。
                            scriptsession.addScript(new ScriptBuffer().appendCall("receive", omsg).appendCall("remove", JSONObject.fromObject(userBean)));
                        }
                    }
                });
                offlineUser = userBean ;
            }
        }
        if(offlineUser!=null){
            users.remove(offlineUser);//在线用户集合中移除此用户。
        }
    }

    /**
     * 将用户id和页面脚本session绑定
     *
     * @param userSessionId
     */
    public void setScriptSessionFlag(String userSessionId) {
        WebContextFactory.get().getScriptSession().setAttribute("userSessionId", userSessionId);
    }

    /**
     * 根据用户id获得指定用户的页面脚本session
     */
    @SuppressWarnings("deprecation")
    public ScriptSession getScriptSession(String sessionId) {
        ScriptSession session = null;

        for (ScriptSession ss : WebContextFactory.get().getAllScriptSessions()) {
            if (sessionId.equals(ss.getId())) {
                session = ss;
                break;
            }
        }
        return session;
    }
    /**
     * 发送消息
     *
     * @param sender     发送者
     * @param receiverid 接收者id
     * @param msg        消息内容
     * @param request
     */
    public void send(final String senderId, final String sender, final String receiverid, final String msg, HttpServletRequest request) {

        if (receiverid != null && !"".equals(receiverid.trim()) && getScriptSession(receiverid) != null) {

            Browser.withSession(getScriptSession(receiverid).getId(), new Runnable() {
                public void run() {
                    JSONObject omsg = new JSONObject();
                    omsg.element("sender", sender);
                    omsg.element("msg", "对你说：" + msg);
                    omsg.element("isAlone", true);
                    getScriptSession(receiverid).addScript(new ScriptBuffer().appendCall("receive", omsg));
                }
            });
        } else {
            Browser.withAllSessions(new Runnable() {

                public void run() {
                    JSONObject omsg = new JSONObject();
                    omsg.element("sender", sender);
                    omsg.element("msg", "：" + msg);
                    omsg.element("isAlone", false);

                    Collection<ScriptSession> sessions = getScriptSessionsByPage(CHAT_PAGE_PATH);
                    System.out.println(sessions.remove(WebContextFactory.get().getScriptSession()));//群发 删除自己。
                    for (ScriptSession scriptsession : sessions) {
                        scriptsession.addScript(new ScriptBuffer().appendCall("receive", omsg));
                    }
                }
            });
        }

    }

    /**
     * 获取某页面的所有链接session
     *
     * @param page
     * @return
     */
    @SuppressWarnings("deprecation")
    public static Collection<ScriptSession> getScriptSessionsByPage(String page) {
        Collection<ScriptSession> sessions = WebContextFactory.get().getScriptSessionsByPage(page);
        return sessions;
    }
}
