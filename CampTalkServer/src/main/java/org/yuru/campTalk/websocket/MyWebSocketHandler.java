package org.yuru.campTalk.websocket;

import org.springframework.stereotype.Service;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@Service
public class MyWebSocketHandler extends TextWebSocketHandler {
    // online users list
    private static final Map<String, WebSocketSession> users;
    // the sign of users
    private static final String CLIENT_ID = "userId";

    static {
        users = new HashMap<>();
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        System.out.println("Connection Success");
        String userId = getClientId(session);
        System.out.println("userId is " + userId);
        if (userId != null) {
            users.put(userId, session);
            session.sendMessage(new TextMessage("Socket Connection Success"));
            System.out.println("session's userId is " + userId);
            System.out.println("session's session is " + session);
        }
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) {
        System.out.println("this message: " + message.getPayload());

        WebSocketMessage messageforsend = new TextMessage("server:" + message);
        try {
            session.sendMessage(messageforsend);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Send information to user.
     * @param clientId
     * @param message
     * @return true or false
     */
    public boolean sendMessageToUser(Integer clientId, TextMessage message) {
        // Set the Key-Value to handle.
        if (users.get(clientId) == null) return false;
        WebSocketSession session = users.get(clientId);
        System.out.println("sendMessage:" + session);
        // return error warnning if failing to opening session
        if (!session.isOpen()) return false;
        try {
            session.sendMessage(message);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    /**
     * Broadcast information.
     * @param message
     * @return allSendSuccess
     */
    public boolean sendMessageToAllUsers(TextMessage message) {
        boolean allSendSuccess = true;
        Set<String> clientIds = users.keySet();
        WebSocketSession session = null;
        for (String clientId : clientIds) {
            try {
                session = users.get(clientId);
                if (session.isOpen()) {
                    session.sendMessage(message);
                }
            } catch (IOException e) {
                e.printStackTrace();
                allSendSuccess = false;
            }
        }

        return  allSendSuccess;
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        if (session.isOpen()) {
            session.close();
        }
        System.out.println("ConnectioneError");
        users.remove(getClientId(session));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        System.out.println("Connection has been closed: " + status);
        users.remove(getClientId(session));
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }

    /**
     * Get an identifier like ip.
     * @param session
     * @return
     */
    private String getClientId(WebSocketSession session) {
        try {
            String clientId = (String)session.getAttributes().get(CLIENT_ID);
            return clientId;
        } catch (Exception e) {
            return null;
        }
    }
}
