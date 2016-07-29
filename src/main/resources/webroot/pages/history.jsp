<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.varentech.deploya.util.ConnectionConfiguration" %>

<!DOCTYPE html>
<%@ page import="java.util.ResourceBundle" %>

<% ResourceBundle resource = ResourceBundle.getBundle("config");
    String tab_name_history = resource.getString("tab_name_history");
    String page_title = resource.getString("page_title");
    String context_path = resource.getString("context_path");
    String port_number = resource.getString("port_number");
    if (session.getAttribute("Username") == null) {
        response.sendRedirect("http://" + request.getServerName() + ":" + port_number + "/" + context_path + "/pages/login.jsp");
        return;
    }
%>
<html lang="en">
<head>
    <title><%=tab_name_history%>
    </title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
    <link rel="stylesheet" href="http://cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css">
    <script type="text/javascript" src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/select/1.2.0/js/dataTables.select.min.js"></script>
    <link rel="stylesheet" href="http://cdn.datatables.net/1.2.0/css/select.dataTables.min.css">
    <script type="text/javascript" src="https://cdn.datatables.net/buttons/1.2.1/js/dataTables.buttons.min.js"></script>
    <link rel="stylesheet" href="http://cdn.datatables.net/buttons/1.2.1/css/buttons.dataTables.min.css">
    <link href="https://gitcdn.github.io/bootstrap-toggle/2.2.2/css/bootstrap-toggle.min.css" rel="stylesheet">
    <script src="https://gitcdn.github.io/bootstrap-toggle/2.2.2/js/bootstrap-toggle.min.js"></script>

</head>
<body>

<div class="container">

    <nav class="navbar navbar-inverse">

        <div class="navbar-header">
            <p class="navbar-brand" href="#"><%=page_title%>
            </p>
        </div>
    </nav>
</div>

<script>var refid = -1;
var table2;
var table3;
var table4;
var table5;
var hide = [];
</script>

<div class="container">
    <ul class="nav nav-tabs" id="myTab">
        <li class="active"><a id="entry" data-toggle="tab" href="#entries" onclick="entriesTabClick();">Entries</a></li>
        <li><a id="detail" data-toggle="tab" href="#entriesDetails" onclick="entriesDetailsTabClick();">EntriesDetails</a>
        </li>
        <li><a id="compareByOutput" data-toggle="tab" href="#compareOutput" class="hidden">CompareOutput</a></li>
        <li><a id="compareByFile" data-toggle="tab" href="#compareFile" class="hidden">CompareFile</a></li>
    </ul>

    <script>
        //adds a parameter to the url if it does not exist or replaces it if it does exist. If called with null paramValue it will delete the param
        function replaceUrlParam(url, paramName, paramValue) {
            var pattern = new RegExp('\\b(' + paramName + '=).*?(&|$)');

            if (url.search(pattern) >= 0) {
                if (paramValue == null) {
                    var urlparts = url.split('?');
                    if (urlparts.length >= 2) {

                        var prefix = encodeURIComponent(paramName) + '=';
                        var pars = urlparts[1].split(/[&;]/g);

                        //reverse iteration as may be destructive
                        for (var i = pars.length; i-- > 0;) {
                            //idiom for string.startsWith
                            if (pars[i].lastIndexOf(prefix, 0) !== -1) {
                                pars.splice(i, 1);
                            }
                        }
                        url = urlparts[0] + (pars.length > 0 ? '?' + pars.join('&') : "");
                        window.history.pushState("", "", url.toString());
                        return url;
                    } else {
                        window.history.pushState("", "", url.toString());
                        return url;
                    }
                } else {
                    window.history.pushState("", "", (url.replace(pattern, '$1' + paramValue + '$2')).toString());
                    return url.replace(pattern, '$1' + paramValue + '$2');
                }

            }

            if (paramValue != null) {
                window.history.pushState("", "", (url + (url.indexOf('?') > 0 ? '&' : '?') + paramName + '=' + paramValue).toString());
                return url + (url.indexOf('?') > 0 ? '&' : '?') + paramName + '=' + paramValue;
            }
        }

        //clears all parameters from the url
        function clearParams(url) {
            var index = 0;
            var newURL = url;
            index = url.indexOf('?');
            if (index == -1) {
                index = url.indexOf('#');
            }
            if (index != -1) {
                newURL = url.substring(0, index);
            }
            window.history.pushState("", "", newURL);
        }

        //clears unecessary parameters from the url when the entries tab is clicked
        function entriesTabClick() {
            replaceUrlParam(window.location.toString(), 'tab', 'entries');
            replaceUrlParam(window.location.toString(), 'page', (table.page.info().page + 1).toString());

            replaceUrlParam(window.location.toString(), 'entryClick');
            replaceUrlParam(window.location.toString(), 'compare1');
            replaceUrlParam(window.location.toString(), 'compare2');
            replaceUrlParam(window.location.toString(), 'page3');
            replaceUrlParam(window.location.toString(), 'page4');

            table.columns().every(function () {
                if (this.search() != "") {
                    replaceUrlParam(window.location.toString(), 'col' + this.index(), this.search());
                } else {
                    replaceUrlParam(window.location.toString(), 'col' + this.index());
                }
            });

        }

        //clears unecessary parameters from the url when the entries details tab is clicked
        function entriesDetailsTabClick() {
            replaceUrlParam(window.location.toString(), 'tab', 'entriesDetails');
            replaceUrlParam(window.location.toString(), 'page', (table2.page.info().page + 1).toString());

            replaceUrlParam(window.location.toString(), 'entryClick');
            replaceUrlParam(window.location.toString(), 'compare1');
            replaceUrlParam(window.location.toString(), 'compare2');
            replaceUrlParam(window.location.toString(), 'page3');
            replaceUrlParam(window.location.toString(), 'page4');

            table2.columns().every(function () {
                if (this.search() != "") {
                    replaceUrlParam(window.location.toString(), 'col' + this.index(), this.search());
                } else {
                    replaceUrlParam(window.location.toString(), 'col' + this.index());
                }
            });

        }

        //occurs when an entry id is clicked on the entries tab. Takes you to entries details tab and filters data
        function entryClick(href) {
            $('#myTab a[href="#entriesDetails"]').tab('show');
            replaceUrlParam(window.location.toString(), 'tab', 'entriesDetails');
            refid = href;
            if (!isNaN(refid)) {
                table2.columns(1).search("^" + refid + "$", true).draw();
                replaceUrlParam(window.location.toString(), 'entryClick', refid);
            }

        }
    </script>

    <div class="tab-content">
        <div id="entries" class="tab-pane fade in active">
            <table id="table1" class="table table-striped">
                <thead>
                <tr>
                    <th>ID:</th>
                    <th>Time Stamp:</th>
                    <th>User Name:</th>
                    <th>File Name:</th>
                    <th>Path to Local File:</th>
                    <th>Path to Destination:</th>
                    <th>Unpack Arguments:</th>
                    <th>Execute Arguments:</th>
                    <th>Archive:</th>
                </tr>
                </thead>

                <tfoot>
                <th>ID:</th>
                <th>Time Stamp:</th>
                <th>User Name:</th>
                <th>File Name:</th>
                <th>Path to Local File:</th>
                <th>Path to Destination:</th>
                <th>Unpack Arguments:</th>
                <th>Execute Arguments:</th>
                <th>Archive:</th>
                </tfoot>

                <tbody>

                <%
                    Class.forName("org.sqlite.JDBC");
                    Connection connection = ConnectionConfiguration.getConnection();
                    Statement statement = connection.createStatement();
                    ResultSet resultSet = statement.executeQuery("SELECT * FROM Entries ORDER BY id DESC");
                    while (resultSet.next()) {
                        String ref = resultSet.getString(1);
                %>

                <tr id="<%=ref%>">
                    <td><a onclick="entryClick(<%=ref%>);"><%=resultSet.getString(1)%>
                    </a></td>
                    <td><%= resultSet.getString(2)%>
                    </td>
                    <td><%= resultSet.getString(3)%>
                    </td>
                    <td><%= resultSet.getString(4)%>
                    </td>
                    <td><%= resultSet.getString(5)%>
                    </td>
                    <td><%= resultSet.getString(6)%>
                    </td>
                    <td><%= resultSet.getString(7)%>
                    </td>
                    <td><%= resultSet.getString(8)%>
                    </td>
                    <td><%= resultSet.getString(9)%>
                    </td>
                </tr>
                <% }
                    resultSet.close();
                    statement.close();
                    connection.close();
                %>
                </tbody>
            </table>

            <script>

                function compareOutput(compare1, compare2) {
                    $('#myTab a[href="#compareOutput"]').tab('show');

                    table3.columns(1).search("^" + compare1.toString() + "$", true).draw();
                    table4.columns(1).search("^" + compare2.toString() + "$", true).draw();
                    table3.rows({search: 'applied'}).data().each(function (value1, index) {
                        var underscore = value1[2].lastIndexOf("_");
                        var fileName1 = value1[2].substring(0, underscore) + value1[2].substring(underscore + 20);
                        table4.rows({search: 'applied'}).data().each(function (value2, index) {
                            var underscore = value2[2].lastIndexOf("_");
                            var fileName2 = value2[2].substring(0, underscore) + value2[2].substring(underscore + 20);
                            if (fileName1 == fileName2) {
                                if (value1[5] != value2[5]) {
                                    $('#c1' + value1[0][0] + value1[0][1] + value1[0][2]).css('background-color', '#ff8c66');
                                    $('#c2' + value2[0][0] + value2[0][1] + value2[0][2]).css('background-color', '#ff8c66');
                                } else if (value1[4] != value2[4]) {
                                    $('#c1' + value1[0][0] + value1[0][1] + value1[0][2]).css('background-color', '#ffe680');
                                    $('#c2' + value2[0][0] + value2[0][1] + value2[0][2]).css('background-color', '#ffe680');
                                }
                            }
                        });
                    });
                }

                function compareFile(compare1, compare2) {
                    $('#myTab a[href="#compareFile"]').tab('show');

                    var run1UserName = table.row('#' + compare1).data()[2];
                    var run1FileName = table.row('#' + compare1).data()[3];
                    var run2UserName = table.row('#' + compare2).data()[2];
                    var run2FileName = table.row('#' + compare2).data()[3];
                    $("#here").replaceWith('<h4 id="here"> Comparing run <a onclick="compare();">' + run1FileName + '</a>, ' + run1UserName + ' to run <a href="#" onclick="compare();">' + run2FileName + '</a>, ' + run2UserName + '.</h4>');

                    table5.clear();

                    table2.columns(1).search("^" + compare1.toString() + "$", true);
                    var run1Array = [];
                    var run2Array = [];
                    table2.rows({search: 'applied'}).data().each(function (value, index) {
                        var underscore = value[2].lastIndexOf("_");
                        var fileName = value[2].substring(0, underscore) + value[2].substring(underscore + 20);
                        run1Array.push([value[0][0] + value[0][1] + value[0][2], fileName, value[3], value[4], value[5]]);
                    });
                    table2.columns(1).search("^" + compare2.toString() + "$", true);
                    table2.rows({search: 'applied'}).data().each(function (value, index) {
                        var underscore = value[2].lastIndexOf("_");
                        var fileName1 = value[2].substring(0, underscore) + value[2].substring(underscore + 20);
                        run2Array.push([value[0][0] + value[0][1] + value[0][2], fileName1, value[3], value[4], value[5], false]);
                    });
                    var rownode;
                    for (var i = 0; i < run1Array.length; i++) {
                        var flag = false;
                        for (var j = 0; j < run2Array.length; j++) {
                            if (run1Array[i][1] == run2Array[j][1]) {
                                run2Array[j][5] = true;
                                flag = true;
                                if (run1Array[i][2] != run2Array[j][2]) {
                                    rownode = table5.row.add([run1Array[i][1], run1Array[i][3], run1Array[i][4]]).draw().node();
                                    $(rownode).css('background-color', '#e0ccff'); //purple changed file
                                } else {
                                    rownode = table5.row.add([run1Array[i][1], run1Array[i][3], run1Array[i][4]]).draw().node();
                                    //rownode.setAttribute("id", "c2" + run1Array[i][0]);
                                    //rownode.to$().attr('id', 'c2' + run1Array[i][0]);
                                    $(rownode).css('background-color', '#dadcd6'); //grey unchanged file
                                    hide.push("c2" + run1Array[i][0]);
                                    //hide.push(run1Array[i][1]);
                                }
                            }
                        }
                        if (flag == false) {
                            rownode = table5.row.add([run1Array[i][1], run1Array[i][3], run1Array[i][4]]).draw().node();
                            $(rownode).css('background-color', '#99ff99'); //green new file
                        }
                    }
                    for (var k = 0; k < run2Array.length; k++) {
                        if (run2Array[k][5] == false) {
                            rownode = table5.row.add([run2Array[k][1], run2Array[k][3], run2Array[k][4]]).draw().node();
                            $(rownode).css('background-color', '#ff8c66'); //red deleted file
                        }
                    }
                }

                $(document).ready(function () {
                    clearParams(window.location.toString());
                    replaceUrlParam(window.location.toString(), 'tab', 'entries');

                    table = $('#table1').DataTable({
                        "order": [[0, "desc"]],
                        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                        select: 'multi',
                        dom: 'Bfrtip',
                        buttons: [
                            {
                                extend: 'selected',
                                text: 'Compare Output',
                                action: function (e, dt, node, config) {
                                    if (table.rows('.selected').data().length != 2) {
                                        alert('Please select 2 runs');
                                    } else {
                                        replaceUrlParam(window.location.toString(), 'tab', 'compareOutput');

                                        var compare1 = table.rows('.selected').ids().toArray()[0];
                                        var compare2 = table.rows('.selected').ids().toArray()[1];
                                        replaceUrlParam(window.location.toString(), 'compare1', compare1);
                                        replaceUrlParam(window.location.toString(), 'compare2', compare2);

                                        compareOutput(compare1, compare2);
                                    }
                                }
                            },
                            {
                                extend: 'selected',
                                text: 'Compare Files',
                                action: function (e, dt, node, config) {
                                    if (table.rows('.selected').data().length != 2) {
                                        alert('Please select 2 runs');
                                    } else {
                                        replaceUrlParam(window.location.toString(), 'tab', 'compareFile');

                                        var compare1 = table.rows('.selected').ids().toArray()[0];
                                        var compare2 = table.rows('.selected').ids().toArray()[1];
                                        replaceUrlParam(window.location.toString(), 'compare1', compare1);
                                        replaceUrlParam(window.location.toString(), 'compare2', compare2);

                                        compareFile(compare1, compare2);
                                    }
                                }
                            }
                        ]
                    });


                    $('#toggle-event').change(function () {
                        var state = $(this).prop('checked');
                        alert(state);
                        for (var i = 0; i < hide.length; i++) {
                            var row = table5.rows(hide[i]);
                            //row.hide();
                            alert(table5.rows(hide[i]).data().length);
                        }
                    });

                    replaceUrlParam(window.location.toString(), 'page', (table.page.info().page + 1).toString());
                    table.on('page', function () {
                        replaceUrlParam(window.location.toString(), 'page', (table.page.info().page + 1).toString());
                    });
                });

            </script>
            <script>
                $(document).ready(function () {
                    // Setup - add a text input to each footer cell
                    $('#table1 tfoot th').each(function () {
                        var title = $(this).text();
                        $(this).html('<input type="text" placeholder="Search ' + title + '" />');
                    });
                    // Apply the search
                    table.columns().every(function () {
                        var that = this;
                        $('input', this.footer()).on('keyup change', function () {
                            if (that.search() !== this.value) {
                                replaceUrlParam(window.location.toString(), 'col' + that.index(), this.value);
                                that.search(this.value).draw();

                                if (that.search() == "") {
                                    replaceUrlParam(window.location.toString(), 'col' + that.index());
                                }
                            }
                        });
                    });

                    table.on('search.dt', function(){
                        alert("yay");
                    });
                });
            </script>

        </div>
        <div id="entriesDetails" class="tab-pane fade">
            <table id="table2" class="table table-striped">
                <thead>
                <tr>
                    <th>ID:</th>
                    <th>Entries Table ID:</th>
                    <th>File Name:</th>
                    <th>Hash Value:</th>
                    <th>Output:</th>
                    <th>Error:</th>
                </tr>
                </thead>

                <tfoot>
                <th>ID:</th>
                <th>Entries Table ID:</th>
                <th>File Name:</th>
                <th>Hash Value:</th>
                <th>Output:</th>
                <th>Error:</th>
                </tfoot>
                <tbody>

                <%
                    Class.forName("org.sqlite.JDBC");
                    Connection entriesDetailsConnection = ConnectionConfiguration.getConnection();
                    Statement entriesDetailsStatement = entriesDetailsConnection.createStatement();
                    ResultSet entriesDetailsResultSet = entriesDetailsStatement.executeQuery("SELECT * FROM Entries_Details ORDER BY id DESC");
                    while (entriesDetailsResultSet.next()) {
                        String ref = entriesDetailsResultSet.getString(2);
                %>
                <tr>
                    <td><%= entriesDetailsResultSet.getString(1) %>
                        <div id=<%=ref%>></div>
                    </td>
                    <td><%= entriesDetailsResultSet.getString(2) %>
                    </td>
                    <td><%= entriesDetailsResultSet.getString(3) %>
                    </td>
                    <td><%= entriesDetailsResultSet.getString(4) %>
                    </td>
                    <td><%= entriesDetailsResultSet.getString(5) %>
                    </td>
                    <td><%= entriesDetailsResultSet.getString(6) %>
                    </td>
                </tr>
                <% }
                    entriesDetailsResultSet.close();
                    entriesDetailsStatement.close();
                    entriesDetailsConnection.close();
                %>
                </tbody>
            </table>

            <script>
                $(document).ready(function () {
                    table2 = $('#table2').DataTable({
                        "order": [[0, "desc"]],
                        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]]
                    });
                    $('#detail').on('click', function (event) {
                        table2.columns(1).search("", true).draw();
                    });

                    table2.on('page', function () {
                        replaceUrlParam(window.location.toString(), 'page', (table2.page.info().page + 1).toString());
                    });
                });
            </script>
            <script>
                $(document).ready(function () {
                    // Setup - add a text input to each footer cell
                    $('#table2 tfoot th').each(function () {
                        var title = $(this).text();
                        $(this).html('<input type="text" placeholder="Search ' + title + '" />');
                    });
                    // Apply the search
                    table2.columns().every(function () {
                        var that = this;
                        $('input', this.footer()).on('keyup change', function () {
                            if (that.search() !== this.value) {
                                replaceUrlParam(window.location.toString(), 'col' + that.index(), this.value);
                                that.search(this.value).draw();

                                if (that.search() == "") {
                                    replaceUrlParam(window.location.toString(), 'col' + that.index());
                                }
                            }
                        });
                    });
                });
            </script>

        </div>
        <div id="compareOutput" class="tab-pane fade">
            <div class="col-md-6">
                <table id="table3" class="table table-striped">
                    <thead>
                    <tr>
                        <th>ID:</th>
                        <th>Entries Table ID:</th>
                        <th>File Name:</th>
                        <th>Hash Value:</th>
                        <th>Output:</th>
                        <th>Error:</th>
                    </tr>
                    </thead>
                    <tbody>

                    <%
                        Class.forName("org.sqlite.JDBC");
                        entriesDetailsConnection = ConnectionConfiguration.getConnection();
                        entriesDetailsStatement = entriesDetailsConnection.createStatement();
                        entriesDetailsResultSet = entriesDetailsStatement.executeQuery("SELECT * FROM Entries_Details ORDER BY id DESC");
                        while (entriesDetailsResultSet.next()) {
                            String ref = "c1" + entriesDetailsResultSet.getString(1);
                    %>
                    <tr id="<%=ref%>">
                        <td><%= entriesDetailsResultSet.getString(1) %>
                            <div id=<%=ref%>></div>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(2) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(3) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(4) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(5) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(6) %>
                        </td>
                    </tr>
                    <% }
                        entriesDetailsResultSet.close();
                        entriesDetailsStatement.close();
                        entriesDetailsConnection.close();
                    %>
                    </tbody>
                </table>
                <script>
                    $(document).ready(function () {
                        table3 = $('#table3').DataTable();
                        table3.columns([0, 3]).visible(false);

                        table3.on('page', function () {
                            replaceUrlParam(window.location.toString(), 'page3', (table3.page.info().page + 1).toString());
                        });
                    });
                </script>
            </div>

            <div class="col-md-6">
                <table id="table4" class="table table-striped">
                    <thead>
                    <tr>
                        <th>ID:</th>
                        <th>Entries Table ID:</th>
                        <th>File Name:</th>
                        <th>Hash Value:</th>
                        <th>Output:</th>
                        <th>Error:</th>
                    </tr>
                    </thead>
                    <tbody>

                    <%
                        Class.forName("org.sqlite.JDBC");
                        entriesDetailsConnection = ConnectionConfiguration.getConnection();
                        entriesDetailsStatement = entriesDetailsConnection.createStatement();
                        entriesDetailsResultSet = entriesDetailsStatement.executeQuery("SELECT * FROM Entries_Details ORDER BY id DESC");
                        while (entriesDetailsResultSet.next()) {
                            String ref = "c2" + entriesDetailsResultSet.getString(1);
                    %>
                    <tr id="<%=ref%>">
                        <td><%= entriesDetailsResultSet.getString(1) %>
                            <div id=<%=ref%>></div>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(2) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(3) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(4) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(5) %>
                        </td>
                        <td><%= entriesDetailsResultSet.getString(6) %>
                        </td>
                    </tr>
                    <% }
                        entriesDetailsResultSet.close();
                        entriesDetailsStatement.close();
                        entriesDetailsConnection.close();
                    %>
                    </tbody>
                </table>
                <script>
                    $(document).ready(function () {
                        table4 = $('#table4').DataTable();
                        table4.columns([0, 3]).visible(false);

                        table4.on('page', function () {
                            replaceUrlParam(window.location.toString(), 'page4', (table4.page.info().page + 1).toString());
                        });
                    });
                </script>
            </div>
        </div>
        <div id="compareFile" class="tab-pane fade">
            <div class="row">
                <div class="col-sm-10">
                    <h4 id="here"></h4>

                </div>
                <div class="col-sm-2" id="hide">
                    <input id="toggle-event" type="checkbox" data-toggle="toggle" data-on="Show Unchanged Files"
                           data-off="Hide Unchanged Files" data-width="175">
                </div>
            </div>
            <div class="row">
                <table id="table5" class="table table-striped">
                    <thead>
                    <tr>
                        <th>File Name:</th>
                        <th>Output:</th>
                        <th>Error:</th>
                    </tr>
                    </thead>
                    <tbody>


                    </tbody>
                </table>
                <script>
                    $(document).ready(function () {
                        table5 = $('#table5').DataTable();
                        table5.on('page', function () {
                            replaceUrlParam(window.location.toString(), 'page', (table5.page.info().page + 1).toString());
                        });
                    });
                </script>

            </div>
        </div>
    </div>
</div>
</body>
</html>