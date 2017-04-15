<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="WebApplication1.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous" />
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
    <title></title>
    <script>
        function validate() {
            alert(document.getElementById('<%=TextBox2.ClientID%>').value);
            var t = null;

            $.getJSON('http://localhost:53227/Home/GetData', function (data) {
                alert(data);
                t = data;
                alert(t);
            });
            return false;
        }
        </script>
</head>
    <style>
        form {
            margin-left:33%;
            
        }
        table {
            width:50%;
        }

        table.interestRates {
            width:50%;
        }

        table tr td {
            padding: 2%;
        }

        .header {
           
            background-color:#337ab7;
            text-align:center;
        }

        .header h2 {
            color: white;
        }
    </style>
<body>
    <div class="container-fluid header" >
        <h2>Lending Club - check your eligibility</h2>
    </div>
    <form id="form1" runat="server">
    <asp:table runat="server" ID="interestRates" CssClass="table table-bordered hide" style="width:50%; margin-top:2%">
            <asp:TableRow >
                <asp:TableCell ColumnSpan="2" style="text-align:center">Interest Rates:</asp:TableCell>
            </asp:TableRow>
        <asp:TableRow style="background:#cccccc">
           <asp:TableCell> <strong>Highest:</strong></asp:TableCell>
            <asp:TableCell> <asp:Label ID="Label17" runat="server"  BorderColor="#009933"></asp:Label></asp:TableCell>
        </asp:TableRow>
            <asp:TableRow>
           <asp:TableCell><strong>Medium:</strong></asp:TableCell><asp:TableCell> <asp:Label ID="Label18" runat="server"></asp:Label></asp:TableCell>
        </asp:TableRow>
            <asp:TableRow>
            <asp:TableCell><strong>Lowest:</strong> </asp:TableCell><asp:TableCell><asp:Label ID="Label19" runat="server"></asp:Label></asp:TableCell>
        </asp:TableRow>

        </asp:table>
        <table>
        <%-- <tr>
        <asp:Label ID="Label2" runat="server"  Text="Lending Club - check your eligibility"></asp:Label>
    </tr>--%>
        <tr>
            <td><asp:Label ID="Label1" runat="server" Text="Loan Amount"></asp:Label></td>
        <td><asp:TextBox ID="TextBox1" CssClass="form-control" runat="server" OnTextChanged="TextBox1_TextChanged"></asp:TextBox></td>
        </tr>
        <tr>
            <td><asp:Label ID="Label3" runat="server" Text="State"></asp:Label></td>
            <td><asp:DropDownList ID="DropDownList1" CssClass="form-control" runat="server" DataSourceID="XmlDataSource1" DataTextField="name" DataValueField="abbreviation">
            </asp:DropDownList>
            <asp:XmlDataSource ID="XmlDataSource1" runat="server" DataFile="~/Properties/us-states.xml"></asp:XmlDataSource></td>
        </tr>
        <tr>
           <td> <asp:Label ID="Label4" runat="server" Text="FICO Score"></asp:Label></td>
        <td><asp:TextBox ID="TextBox2" CssClass="form-control" runat="server"></asp:TextBox></td>
        </tr>
        <tr>
            <td><asp:Label ID="Label5" runat="server" Text="Employment Length"></asp:Label></td>
        <td><asp:TextBox ID="TextBox3" CssClass="form-control" runat="server" OnTextChanged="TextBox3_TextChanged"></asp:TextBox></td>
        </tr>
        <tr>
        <td><asp:Button ID="Button1" CssClass="btn btn-primary" runat="server" Text="Submit" OnClick="Button1_Click" OnClientClick="return validate();" /></td>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <td><asp:Button ID="Button2" CssClass="btn btn-primary" runat="server" Enabled="False" OnClick="Button2_Click" Text="Next" /></td>
        </tr>
        <tr>
            <td colspan="2"><asp:Label ID="Label6" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td><asp:Label ID="Label16" runat="server" Text="Annual Income" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox12" CssClass="form-control" runat="server" OnTextChanged="TextBox6_TextChanged" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
           <td> <asp:Label ID="Label7" runat="server" Text="Sub-Grade" Visible="False"></asp:Label></td>
       <td> <asp:TextBox ID="TextBox6" CssClass="form-control" runat="server" OnTextChanged="TextBox6_TextChanged" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
            <td><asp:Label ID="Label11" runat="server" Text="Loan Term" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox7" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
            <td><asp:Label ID="Label12" runat="server" Text="Bank Card Accounts" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox10" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
           <td> <asp:Label ID="Label13" runat="server" Text="Issue Year" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox11" CssClass="form-control" runat="server" OnTextChanged="TextBox11_TextChanged" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
            <td><asp:Label ID="Label14" runat="server" Text="No of Trade Account opened past 24 months" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox4" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
           <td> <asp:Label ID="Label15" runat="server" Text="Months since recent Trade" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox8" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
           <td><asp:Label ID="Label9" runat="server" Text="Deliquency in 2 yrs" Visible="False"></asp:Label></td>
        <td><asp:TextBox ID="TextBox5" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
        </tr>
        <tr>
            <td><asp:Button ID="Button3" CssClass="btn btn-primary" runat="server" OnClick="Button3_Click" Text="Calculate Interest" Visible="False" /></td>
            <td><input type="reset" value="Reset" runat="server" id="reset" class="btn btn-primary hide" /></td>
        </tr>
             <tr>
            <td><asp:TextBox ID="TextSubGradeChange" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
            <td><asp:TextBox ID="TextStateChange" CssClass="form-control" runat="server" Visible="False"></asp:TextBox></td>
        </tr>
        </table>
        
    </form>
</body>
</html>