<%@ page contentType="text/html;charset=UTF-8"
  import="org.apache.hadoop.io.Text"
  import="org.apache.hadoop.hbase.HTableDescriptor"
  import="org.apache.hadoop.hbase.client.HTable"
  import="org.apache.hadoop.hbase.HRegionInfo"
  import="org.apache.hadoop.hbase.HServerAddress"
  import="org.apache.hadoop.hbase.HServerInfo"
  import="org.apache.hadoop.hbase.master.HMaster" 
  import="org.apache.hadoop.hbase.master.MetaRegion"
  import="java.io.IOException"
  import="java.util.Map"
  import="org.apache.hadoop.hbase.HConstants"%><%
  HMaster master = (HMaster)getServletContext().getAttribute(HMaster.MASTER);
  String tableName = request.getParameter("name");
  HTable table = new HTable(master.getConfiguration(), new Text(tableName));
  Map<String, HServerInfo> serverToServerInfos =
	    master.getServersToServerInfo();
  String tableHeader = "<table><tr><th>Name</th><th>Region Server</th><th>Encoded Name</th><th>Start Key</th><th>End Key</th></tr>";
  HServerAddress rootLocation = master.getRootRegionLocation();
%><?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head><meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
<title>Regions in <%= tableName %></title>
<link rel="stylesheet" type="text/css" href="/static/hbase.css" />
</head>

<body>
<a id="logo" href="http://wiki.apache.org/lucene-hadoop/Hbase"><img src="/static/hbase_logo_med.gif" alt="HBase Logo" title="HBase Logo" /></a>
<h1 id="page_title">Regions in <%= tableName %></h1>
<p id="links_menu"><a href="/master.jsp">Master</a>, <a href="/logs/">Local logs</a>, <a href="/stacks">Thread Dump</a>, <a href="/logLevel">Log Level</a></p>
<hr id="head_rule" />

<%if(tableName.equals(HConstants.ROOT_TABLE_NAME.toString())) {%>
<%= tableHeader %>
<%  int infoPort = serverToServerInfos.get(rootLocation.getBindAddress()+":"+rootLocation.getPort()).getInfoPort();
    String url = "http://" + rootLocation.getBindAddress() + ":" + infoPort + "/";%> 
<tr><td><%= tableName %></td><td><a href="<%= url %>"><%= rootLocation.getHostname() %>:<%= rootLocation.getPort() %></a></td><td>-</td><td></td><td>-</td></tr>
</table>
<%} else if(tableName.equals(HConstants.META_TABLE_NAME.toString())) { %>
<%= tableHeader %>
<%  Map<Text, MetaRegion> onlineRegions = master.getOnlineMetaRegions();
    for (MetaRegion meta: onlineRegions.values()) {
      int infoPort = serverToServerInfos.get(meta.getServer().getBindAddress()+":"+meta.getServer().getPort()).getInfoPort();
      String url = "http://" + meta.getServer().getHostname() + ":" + infoPort + "/";%> 
<tr><td><%= meta.getRegionName() %></td><td><a href="<%= url %>"><%= meta.getServer().getHostname() %>:<%= meta.getServer().getPort() %></a></td><td>-</td><td><%= meta.getStartKey() %></td><td>-</td></tr>
<%  } %>
</table>
<%} else { %>
    
<% 
    try {
	  Map<HRegionInfo, HServerAddress> regions = table.getRegionsInfo(); 
      if(regions != null && regions.size() > 0) { %>
<%=     tableHeader %>
<%      for(Map.Entry<HRegionInfo, HServerAddress> hriEntry : regions.entrySet()) { %>
<%        System.out.println(serverToServerInfos.keySet().toArray()[0].toString());
          System.out.println(hriEntry.getValue().getHostname()+":"+hriEntry.getValue().getPort());
          int infoPort = serverToServerInfos.get(hriEntry.getValue().getBindAddress()+":"+hriEntry.getValue().getPort()).getInfoPort();
          String url = "http://" + hriEntry.getValue().getHostname().toString() + ":" + infoPort + "/";  %>
<tr><td><%= hriEntry.getKey().getRegionName()%></td><td><a href="<%= url %>"><%= hriEntry.getValue().getHostname() %>:<%= hriEntry.getValue().getPort() %></a></td>
    <td><%= hriEntry.getKey().getEncodedName()%></td> <td><%= hriEntry.getKey().getStartKey()%></td>
    <td><%= hriEntry.getKey().getEndKey()%></td></tr>
<%      } %>
</table>
<%    } 
    }
    catch(IOException ioe) { } 
  }%>
</body>
</html>
