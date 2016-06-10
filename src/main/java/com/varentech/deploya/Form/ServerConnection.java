package com.varentech.deploya.Form;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.glassfish.jersey.server.ResourceConfig;
import org.glassfish.jersey.servlet.ServletContainer;

public class ServerConnection
{
    public void connect()
    {
        ResourceConfig config = new ResourceConfig();
        config.packages("com/varentech/deploya");
        ServletHolder servlet;
        servlet = new ServletHolder(new ServletContainer(config));

        Server server = new Server(2222);
        ServletContextHandler context;
        context = new ServletContextHandler(server, "/*");
        context.addServlet(servlet,"/*");

        try{
            server.start();
            server.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        } finally{
            server.destroy();
        }
    }
}