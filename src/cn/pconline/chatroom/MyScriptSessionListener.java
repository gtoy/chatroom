package cn.pconline.chatroom;

import java.util.Collection;

import net.sf.json.JSONObject;

import org.directwebremoting.Browser;
import org.directwebremoting.ScriptBuffer;
import org.directwebremoting.ScriptSession;
import org.directwebremoting.WebContextFactory;
import org.directwebremoting.event.ScriptSessionEvent;
import org.directwebremoting.event.ScriptSessionListener;

public class MyScriptSessionListener implements ScriptSessionListener {
//	public static ArrayList scriptSession_list=new ArrayList();
	public MyScriptSessionListener() {
		System.out.println("监听器初始化");
	}
	public void sessionCreated(ScriptSessionEvent event) {
//		scriptSession_list.add(event.getSession());
//		System.out.println(event.getSession().getId()); //创建ScriptSession
	}
	public void sessionDestroyed(ScriptSessionEvent event) {
//		event.getSession().invalidate();//使ScriptSession作废
		UserBean userbean=null;
		for (UserBean user:Handler.users){
			if(user.getSessionId().equals(event.getSession().getId())){
				userbean=user;
			}
		}
		Handler.users.remove(userbean);//更新users列表
		Handler.updateUsersList("null", false,null);
		if(userbean!=null){
			final String name=userbean.getName();
			Browser.withAllSessions(WebContextFactory.get(),new Runnable() {

				@SuppressWarnings("deprecation")
				public void run() {
					Collection<ScriptSession> sessions=WebContextFactory.get().getScriptSessionsByPage(Handler.CHAT_PAGE_PATH);
					JSONObject omsg=new JSONObject();

					omsg.element("sender", "系统消息");
					omsg.element("msg", "：["+name+"]已下线！");
					omsg.element("isAlone",false);
					for(ScriptSession scriptsession:sessions){
						scriptsession.addScript(new ScriptBuffer().appendCall("receive",omsg));
					}
				}
			});
		}

//		scriptSession_list.remove(event.getSession());
//		System.out.println("作废ScriptSession:"+event.getSession().getId());
	}
}
