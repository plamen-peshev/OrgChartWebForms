<%@ Page Language="C#" %>

<script type="text/c#" runat="server">
    public void Page_Load(object sender, EventArgs e)
    {
        var jsonSerialization = new System.Web.Script.Serialization.JavaScriptSerializer();

        if (!IsPostBack)
        {
            if (Session["Nodes"] == null)
            {
                List<Node> list = new List<Node>();
                list.Add(new Node
                {
                    id = "1",
                    name = "Name 1"
                });

                list.Add(new Node
                {
                    id = "2",
                    pid = "1",
                    name = "Name 2"
                });

                Session["Nodes"] = jsonSerialization.Serialize(list);
            }
        }
    }

    [System.Web.Services.WebMethod]
    public static void Add(string id, string pid)
    {
        var jsonSerialization = new System.Web.Script.Serialization.JavaScriptSerializer();
        var list = jsonSerialization.Deserialize<List<Node>>((string)HttpContext.Current.Session["Nodes"]);
        list.Add(new Node
        {
            id = id,
            pid = pid
        });
        HttpContext.Current.Session["Nodes"] = jsonSerialization.Serialize(list);
    }

    [System.Web.Services.WebMethod]
    public static void Remove(string id)
    {
        var jsonSerialization = new System.Web.Script.Serialization.JavaScriptSerializer();
        var list = jsonSerialization.Deserialize<List<Node>>((string)HttpContext.Current.Session["Nodes"]);
        Node removeItem = null;
        foreach (var item in list)
        {
            if (item.id == id)
            {
                removeItem = item;
                break;
            }
        }
        list.Remove(removeItem);
        HttpContext.Current.Session["Nodes"] = jsonSerialization.Serialize(list);
    }

    [System.Web.Services.WebMethod]
    public static void Update(Node oldNode, Node newNode)
    {
        var jsonSerialization = new System.Web.Script.Serialization.JavaScriptSerializer();
        var list = jsonSerialization.Deserialize<List<Node>>((string)HttpContext.Current.Session["Nodes"]);

        foreach (var item in list)
        {
            if (item.id == newNode.id)
            {
                item.pid = newNode.pid;
                item.name = newNode.name;
                break;
            }
        }
        HttpContext.Current.Session["Nodes"] = jsonSerialization.Serialize(list);
    }

    public class Node
    {
        public string id { get; set; }
        public string pid { get; set; }
        public string name { get; set; }
    }

</script>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="https://balkangraph.com/js/latest/OrgChart.js"></script>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
    <style type="text/css">
        html, body {
            margin: 0px;
            padding: 0px;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        #tree {
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="scm" runat="server" EnablePageMethods="true" />
        <div id="tree"></div>
    </form>

    <script>


        var chart = new OrgChart(document.getElementById("tree"), {
            nodeBinding: {
                field_0: "name"
            },
            nodeMenu: {
                details: { text: "Details" },
                add: { text: "Add New" },
                edit: { text: "Edit" },
                remove: { text: "Remove" },
            }
        });

        chart.on('add', function (sender, n) {
            $.ajax({
                type: 'POST',
                url: '<%= ResolveUrl("~/Default.aspx/Add") %>',
                data: JSON.stringify(n),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json'
            });
        });


        chart.on('remove', function (sender, id) {
            $.ajax({
                type: 'POST',
                url: '<%= ResolveUrl("~/Default.aspx/Remove") %>',
                data: JSON.stringify({ id: id }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json'
            });
        });

        chart.on('update', function (sender, oldNode, newNode) {
            $.ajax({
                type: 'POST',
                url: '<%= ResolveUrl("~/Default.aspx/Update") %>',
                data: JSON.stringify({ oldNode: oldNode, newNode: newNode }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json'
            });
        });

        chart.load(<%= Session["Nodes"] %>);
    </script>
</body>
</html>
