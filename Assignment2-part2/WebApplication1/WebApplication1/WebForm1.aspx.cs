using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Json;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;


namespace WebApplication1
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        String temp1;
        String temp2;
        String temp3;
        String temp4;
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {

            string classname = "alert alert-success";
            // add a class
            


             temp1 = TextBox1.Text;
             temp2 = TextBox2.Text;
             temp3 = TextBox3.Text;
             temp4 = DropDownList1.SelectedValue;
            Console.Write("Invoking web services");
            int isClassficcation = Convert.ToInt32(PredictClassification());
            if (isClassficcation == 0)
            {
                Label6.CssClass = "alert alert-danger";
                Label6.Text = "You are not applicable for LOAN"; 
                //Response.Redirect("RejectedLoan.aspx");
            }
            else
            {
                Label6.CssClass = "alert alert-success";
                Label6.Text = "To check your interest click next";
                Button2.Enabled = true;
            }

        }
        
        protected string PredictClassification()
        {
            Console.Write("Forming Jason Object");
            using (var client = new HttpClient())
            {
                var scoreRequest = new
                {
                    Inputs = new Dictionary<string, List<Dictionary<string, string>>>() {
                        {
                            "input1",
                            new List<Dictionary<string, string>>(){new Dictionary<string, string>(){
                                            {
                                                "loan_amnt", TextBox1.Text
                                            },
                                            {
                                                "FicoScore", TextBox2.Text
                                            },
                                            {
                                                "emp_length", TextBox3.Text
                                            },
                                            {
                                                "addr_state", DropDownList1.SelectedValue
                                            },
                                }
                            }
                        },
                    },
                    GlobalParameters = new Dictionary<string, string>()
                    {
                    }
                };
                Console.Write("Jason object created");
                Console.Write("Connecting to Werb service ======>");
                const string apiKey = "ujM1au5E4i0z9TZ79nf6GCWoI10Kzosjh9+ZxyIv838y5nl70cxuaxOEl2QTrjN+f5gqYU6l4XXmcSVuju/zGw=="; // Replace this with the API key for the web service
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                client.BaseAddress = new Uri("https://ussouthcentral.services.azureml.net/workspaces/c14b5621c36e4dd39eff980ac3611639/services/4c19f99f7ab748f988095e8ec1a90d78/execute?api-version=2.0&format=swagger");
                // WARNING: The 'await' statement below can result in a deadlock
                // if you are calling this code from the UI thread of an ASP.Net application.
                // One way to address this would be to call ConfigureAwait(false)
                // so that the execution does not attempt to resume on the original context.
                // For instance, replace code such as:
                //      result = await DoSomeTask()
                // with the following:
                //      result = await DoSomeTask().ConfigureAwait(false)

                HttpResponseMessage response = client.PostAsJsonAsync("", scoreRequest).Result;
                string output= null;
                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine("Sending Request");
                    String result = response.Content.ReadAsStringAsync().Result;
                    // JObject responseData = JObject.Parse(result);
                    dynamic jsonData = JsonConvert.DeserializeObject<dynamic>(result);
                    output = jsonData.Results.output1[0]["Scored Labels"];
                    //txtResult.Text = cnic;
                    Console.WriteLine("Result: {0}", result);
                }
                else
                {
                    Console.WriteLine(string.Format("The request failed with status code: {0}", response.StatusCode));
                    // Print the headers - they include the requert ID and the timestamp,
                    // which are useful for debugging the failure
                    Console.WriteLine(response.Headers.ToString());

                    string responseContent = response.Content.ReadAsStringAsync().Result;
                    Console.WriteLine(responseContent);
                }
                return output;
            }
        }

        protected void stateList_Transforming(object sender, EventArgs e)
        {

        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            Label16.Visible = true;
            Label15.Visible = true;
            Label14.Visible = true;
            Label13.Visible = true;
            Label12.Visible = true;
            Label11.Visible = true;
            Label9.Visible = true;
            Label7.Visible = true;
            TextBox4.Visible = true;
            TextBox5.Visible = true;
            TextBox6.Visible = true;
            TextBox7.Visible = true;
            TextBox8.Visible = true;
            TextBox12.Visible = true;
            TextBox10.Visible = true;
            TextBox11.Visible = true;
            Button3.Visible = true;
            
            
            reset.Attributes.Add("class", reset.Attributes["class"].Replace("hide", "")); 
        }

        protected void TextBox6_TextChanged(object sender, EventArgs e)
        {

        }

        protected void TextBox11_TextChanged(object sender, EventArgs e)
        {

        }

        protected void Button3_Click(object sender, EventArgs e)
        {
            interestRates.CssClass = interestRates.CssClass.Replace("hide", "");
            double int_pred1 = manualCluster();
            double int_pred2 = clusterAlgo();
            double int_pred3 = noCluster();
             
            if (int_pred1 >= int_pred2)
            {
                if(int_pred1>=int_pred3)
                {
                    Label17.Text = int_pred1.ToString() + "  --  Manual Cluster";
                    Label18.Text = int_pred3.ToString() + "  --  No Cluster";
                    Label19.Text = int_pred2.ToString() + "  --  Cluster Algorithm";
                }
                else
                {
                    Label17.Text = int_pred3.ToString() + "  --  No Algorithm";
                    Label18.Text = int_pred1.ToString() + "  --  Manual Cluster";
                    Label19.Text = int_pred2.ToString() + "  --  Cluster Algorithm";
                }
            }
            else
            {
                if (int_pred2 >= int_pred3)
                {
                    Label17.Text = int_pred2.ToString() + "  --  Cluster Algorithm";
                    Label18.Text = int_pred3.ToString() + "  --  No Algorithm";
                    Label19.Text = int_pred1.ToString() + "  --  Manual Cluster"; ;
                }
                else
                {
                    Label17.Text = int_pred3.ToString() + "  --  No Algorithm";
                    Label18.Text = int_pred2.ToString() + "  --  Cluster Algorithm";
                    Label19.Text = int_pred1.ToString() + "  --  Manual Cluster"; ;
                }
            }
        }
        public double manualCluster()
        {
            int count = 0;
            String API = "";
            String URL = "";
            double interestManual = 0;
            int returnVal = 0;

            int fico = Convert.ToInt32(TextBox2.Text);
            int income = Convert.ToInt32(TextBox12.Text);
            int emp_length = Convert.ToInt32(TextBox3.Text);
            String state = DropDownList1.SelectedValue;
            String [] state1 = {"WA","DC","CO","UT","NE","MA","NV","SD","FL","CA","ID","NY","OR","NH","MN","IA","CT"};
            String [] state2 = {"VA","NJ","DE","HI","MD","OH","VT","AZ","MI","NC","GA","TX","WI","MT","PA","RI","ME"};
            String [] state3 = {"SC","IN","TN","IL","KY","AK","KS","MO","ND","AR","AL","MS","WY","LA","OK","NM","WV"};

            if(fico >= 300)
            {
                count++;
            }
            else if (fico >= 450)
            {
                count++;
            }
            else if (fico >= 650)
            {
                count++;
            }

            if (income >= 0)
            {
                count++;
            }
            else if (income >= 40000)
            {
                count++;
            }
            else if (income >= 96000)
            {
                count++;
            }

            if (emp_length >= 0)
            {
                count++;
            }
            else if (emp_length >= 4)
            {
                count++;
            }
            else if (emp_length >= 8)
            {
                count++;
            }

            for (int i = 0; i < 17; ++i)
            {
                if(state == state1[i]){
                    count ++;
                }else if(state == state2[i]){
                    count ++;
                }else if(state == state3[i]){
                    count ++;
                }
            }

            if (3 < count && count < 7)
            {
                returnVal = 1;
            }
            else if (6 < count && count < 10)
            {
                returnVal = 2;
            }
            else if (9 < count && count < 13)
            {
                returnVal = 3;
            }

            if (returnVal == 1)
            {
                API = "N3dTjubyAxbbwybvVIe73XVkb/c20uTBZ9eVCHWn2teb6JnpxdSsYkPnmZZ2WyyGuPDtG2RIv/sNqhRqh2B5Kw==";
                URL = "https://ussouthcentral.services.azureml.net/workspaces/c14b5621c36e4dd39eff980ac3611639/services/71f5749965d448d1879e892f35a88a48/execute?api-version=2.0&format=swagger";
                interestManual = Convert.ToDouble(RequestPrediction(API, URL));

            }
            if (returnVal == 2)
            {
                API = "T6pYz2MTC0DLz1zi3XBPRL+xfi5SqdfOppzhqeJV8Zjy/vNvFVakI/BsTtQetC7SF1j9y53olfkZ2Z80l5BACw==";
                URL = "https://ussouthcentral.services.azureml.net/workspaces/c14b5621c36e4dd39eff980ac3611639/services/0b24cd3c44d04d2db69f3ea48506bfcb/execute?api-version=2.0&format=swagger";
                interestManual = Convert.ToDouble(RequestPrediction(API, URL));
            }
            if (returnVal == 3)
            {
                API = "tAY6HcCQG/65/YsxhLwFS8kvowi/eU7kgO4P8MrJQx2dQ3b6uMHds55+53jYeuXHo9jqhhf55nT8xDXc8upzRA==";
                URL = "https://ussouthcentral.services.azureml.net/workspaces/c14b5621c36e4dd39eff980ac3611639/services/bd6d1cbcc7724e9dbfb5b67331e9a5d4/execute?api-version=2.0&format=swagger";
                interestManual = Convert.ToDouble(RequestPrediction(API, URL));
            }

            return interestManual;
        }

        public double clusterAlgo()
        {
            String API1 = "";
            String URL1 = "";
            double interestManual = 0;

            String subGrade = TextBox6.Text;
            String addrState = DropDownList1.SelectedValue;

            switch (subGrade)
            {
                case "A1":
                    TextSubGradeChange.Text = "1";
                    break;
                case "A2":
                    TextSubGradeChange.Text = "2";
                    break;
                case "A3":
                    TextSubGradeChange.Text = "3";
                    break;
                case "A4":
                    TextSubGradeChange.Text = "4";
                    break;
                case "A5":
                    TextSubGradeChange.Text = "5";
                    break;
                case "B1":
                    TextSubGradeChange.Text = "6";
                    break;
                case "B2":
                    TextSubGradeChange.Text = "7";
                    break;
                case "B3":
                    TextSubGradeChange.Text = "8";
                    break;
                case "B4":
                    TextSubGradeChange.Text = "9";
                    break;
                case "B5":
                    TextSubGradeChange.Text = "10";
                    break;
                case "C1":
                    TextSubGradeChange.Text = "11";
                    break;
                case "C2":
                    TextSubGradeChange.Text = "12";
                    break;
                case "C3":
                    TextSubGradeChange.Text = "13";
                    break;
                case "C4":
                    TextSubGradeChange.Text = "14";
                    break;
                case "C5":
                    TextSubGradeChange.Text = "15";
                    break;
                case "D1":
                    TextSubGradeChange.Text = "16";
                    break;
                case "D2":
                    TextSubGradeChange.Text = "17";
                    break;
                case "D3":
                    TextSubGradeChange.Text = "18";
                    break;
                case "D4":
                    TextSubGradeChange.Text = "19";
                    break;
                case "D5":
                    TextSubGradeChange.Text = "20";
                    break;
                case "E1":
                    TextSubGradeChange.Text = "21";
                    break;
                case "E2":
                    TextSubGradeChange.Text = "22";
                    break;
                case "E3":
                    TextSubGradeChange.Text = "23";
                    break;
                case "E4":
                    TextSubGradeChange.Text = "24";
                    break;
                case "E5":
                    TextSubGradeChange.Text = "25";
                    break;
                case "F1":
                    TextSubGradeChange.Text = "26";
                    break;
                case "F2":
                    TextSubGradeChange.Text = "27";
                    break;
                case "F3":
                    TextSubGradeChange.Text = "28";
                    break;
                case "F4":
                    TextSubGradeChange.Text = "29";
                    break;
                case "F5":
                    TextSubGradeChange.Text = "30";
                    break;
                case "G1":
                    TextSubGradeChange.Text = "31";
                    break;
                case "G2":
                    TextSubGradeChange.Text = "32";
                    break;
                case "G3":
                    TextSubGradeChange.Text = "33";
                    break;
                case "G4":
                    TextSubGradeChange.Text = "34";
                    break;
                case "G5":
                    TextSubGradeChange.Text = "35";
                    break;
            }

            switch (addrState)
            {
                case "AK":
                    TextStateChange.Text = "1";
                    break;
                case "AL":
                    TextStateChange.Text = "2";
                    break;
                case "AR":
                    TextStateChange.Text = "3";
                    break;
                case "AZ":
                    TextStateChange.Text = "4";
                    break;
                case "CA":
                    TextStateChange.Text = "5";
                    break;
                case "CO":
                    TextStateChange.Text = "6";
                    break;
                case "CT":
                    TextStateChange.Text = "7";
                    break;
                case "DC":
                    TextStateChange.Text = "8";
                    break;
                case "DE":
                    TextStateChange.Text = "9";
                    break;
                case "FL":
                    TextStateChange.Text = "10";
                    break;
                case "GA":
                    TextStateChange.Text = "11";
                    break;
                case "HI":
                    TextStateChange.Text = "12";
                    break;
                case "IA":
                    TextStateChange.Text = "13";
                    break;
                case "ID":
                    TextStateChange.Text = "14";
                    break;
                case "IL":
                    TextStateChange.Text = "15";
                    break;
                case "IN":
                    TextStateChange.Text = "16";
                    break;
                case "KS":
                    TextStateChange.Text = "17";
                    break;
                case "KY":
                    TextStateChange.Text = "18";
                    break;
                case "LA":
                    TextStateChange.Text = "19";
                    break;
                case "MA":
                    TextStateChange.Text = "20";
                    break;
                case "MD":
                    TextStateChange.Text = "21";
                    break;
                case "ME":
                    TextStateChange.Text = "22";
                    break;
                case "MI":
                    TextStateChange.Text = "23";
                    break;
                case "MN":
                    TextStateChange.Text = "24";
                    break;
                case "MO":
                    TextStateChange.Text = "25";
                    break;
                case "MS":
                    TextStateChange.Text = "26";
                    break;
                case "MT":
                    TextStateChange.Text = "27";
                    break;
                case "NC":
                    TextStateChange.Text = "28";
                    break;
                case "ND":
                    TextStateChange.Text = "29";
                    break;
                case "NE":
                    TextStateChange.Text = "30";
                    break;
                case "NH":
                    TextStateChange.Text = "31";
                    break;
                case "NJ":
                    TextStateChange.Text = "32";
                    break;
                case "NM":
                    TextStateChange.Text = "33";
                    break;
                case "NV":
                    TextStateChange.Text = "34";
                    break;
                case "NY":
                    TextStateChange.Text = "35";
                    break;
                case "OH":
                    TextStateChange.Text = "36";
                    break;
                case "OK":
                    TextStateChange.Text = "37";
                    break;
                case "OR":
                    TextStateChange.Text = "38";
                    break;
                case "PA":
                    TextStateChange.Text = "39";
                    break;
                case "RI":
                    TextStateChange.Text = "40";
                    break;
                case "SC":
                    TextStateChange.Text = "41";
                    break;
                case "SD":
                    TextStateChange.Text = "42";
                    break;
                case "TN":
                    TextStateChange.Text = "43";
                    break;
                case "TX":
                    TextStateChange.Text = "44";
                    break;
                case "UT":
                    TextStateChange.Text = "45";
                    break;
                case "VA":
                    TextStateChange.Text = "46";
                    break;
                case "VT":
                    TextStateChange.Text = "47";
                    break;
                case "WA":
                    TextStateChange.Text = "48";
                    break;
                case "WI":
                    TextStateChange.Text = "49";
                    break;
                case "WV":
                    TextStateChange.Text = "50";
                    break;
                case "WY":
                    TextStateChange.Text = "51";
                    break;
                default:
                    TextStateChange.Text = "51";
                    break;
            }

            String API = "darTrYO8BqMbqT2c7LDNGDGVUXTSZvh5DPtwMsyNvZ6KOEtu6vDW+bBbOvuV14L15rUtg9F/wUsqNDDav3bKiw==";
            String URL = "https://ussouthcentral.services.azureml.net/workspaces/c14b5621c36e4dd39eff980ac3611639/services/c17c792b18ff4d39949ca98da4102815/execute?api-version=2.0&format=swagger";
            int cluster = Convert.ToInt32(RequestCluster(API, URL));

            switch (cluster)
            {
                case 0:
                    API1 = "qPtNUhJ1nIJWZbGos6aiqzOlqfhgjaKgyWqhxHXhJZWnsPKtf50fJVL5OAcrS2dsTEXxpVbMztwfbUTsrhZ+Uw==";
                    URL1 = "https://ussouthcentral.services.azureml.net/workspaces/c4a84d4c31994c3d979a9e4859607c65/services/40e906b37b4947e2a73f931aff5ea3fb/execute?api-version=2.0&format=swagger";
                    interestManual = Convert.ToDouble(RequestPrediction1(API1, URL1));
                    break;
                case 1:
                    API1 = "Lic/F+b0iQWCRFTCU+9I2hzKDxkwltJYTL4vL5wYpn87stumt3mdUlWIqqLngbRItsEm4yYzs21FZbLO99axNg==";
                    URL1 = "https://ussouthcentral.services.azureml.net/workspaces/c4a84d4c31994c3d979a9e4859607c65/services/14fb1500a02747e0aba240ac68187409/execute?api-version=2.0&format=swagger";
                    interestManual = Convert.ToDouble(RequestPrediction1(API1, URL1));
                    break;
                case 2: 
                    API1 = "7Hp3QuSqVp+fzPBvXxKCnCQRUmGFy0/MwQCpHfmv+K0Am8Oo7ns2rI40e0R3mq0gJLyf2YGI5FwxM1iSEMKjTA==";
                    URL1 = "https://ussouthcentral.services.azureml.net/workspaces/c4a84d4c31994c3d979a9e4859607c65/services/795c3d064163453e96f9e295eafb5b40/execute?api-version=2.0&format=swagger";
                    interestManual = Convert.ToDouble(RequestPrediction1(API1, URL1));
                    break;
                case 3: 
                    API1 = "SCsp3ZE7JsuxMIfjRJNkKgUnOo/Mu5UO+1D88zTERHo+bojWiy8vUe6SLiAsQhScGVNoAzNhgkO00DlQeDSRUg==";
                    URL1 = "https://ussouthcentral.services.azureml.net/workspaces/c4a84d4c31994c3d979a9e4859607c65/services/63df5eaed66e40cbb10d74c4e047019d/execute?api-version=2.0&format=swagger";
                    interestManual = Convert.ToDouble(RequestPrediction1(API1, URL1));
                    break;
                case 4:
                    API1 = "nnmMi5Lfb/YMs32cMIOD7P1X9dx9UDEOdF1bF6XOyomA/5/3G7a9RVJWLcRjXQPHDPWeHffTGjItpZwhdph9Iw==";
                    URL1 = "https://ussouthcentral.services.azureml.net/workspaces/c4a84d4c31994c3d979a9e4859607c65/services/839e2f79af784088aea4b8bf3aa0c64f/execute?api-version=2.0&format=swagger";
                    interestManual = Convert.ToDouble(RequestPrediction1(API1, URL1)); 
                    break;
            }
                return interestManual;

        }
        public double noCluster()
        {

            String API = "N85mFh5j2aIp/nyaMzSO9HfTH5wtZJ7OClbnZnmZzG7SW94mUMQRBiCASxBGZpdqo1Nzr8dJQ4ko5z+73G0POg==";
            String URL = "https://ussouthcentral.services.azureml.net/workspaces/c4a84d4c31994c3d979a9e4859607c65/services/d96ad730dd394e58b3fb19bdcd71e1fe/execute?api-version=2.0&format=swagger";
            double interestManual = Convert.ToDouble(RequestPrediction(API, URL));
            return interestManual;

        }

        protected void TextBox1_TextChanged(object sender, EventArgs e)
        {
            //clear all and then set all to first setting
        }

        protected string RequestPrediction(String API, String URL)
        {
            Console.Write("Forming Jason Object");
            using (var client = new HttpClient())
            {
                var scoreRequest = new
                {
                    Inputs = new Dictionary<string, List<Dictionary<string, string>>>() {
                        {
                            "input1",
                            new List<Dictionary<string, string>>(){new Dictionary<string, string>(){
                                            {
                                                "sub_grade", TextBox6.Text
                                            },
                                            {
                                                "loan_amnt", TextBox1.Text
                                            },
                                            {
                                                "Derived_term", TextBox7.Text
                                            },
                                            {
                                                "issue_year", TextBox11.Text
                                            },
                                            {
                                                "percent_bc_gt_75", TextBox10.Text
                                            },
                                            {
                                                "num_tl_op_past_12m", TextBox4.Text
                                            },
                                            {
                                                "mo_sin_rcnt_tl", TextBox8.Text
                                            },
                                            {
                                                "FicoScore", TextBox2.Text
                                            },
                                            {
                                                "addr_state", DropDownList1.SelectedValue
                                            },
                                            {
                                                "emp_length", TextBox3.Text
                                            },
                                            {
                                                "annual_inc", TextBox12.Text
                                            },
                                            {
                                                "delinq_2yrs", TextBox5.Text
                                            },
                                }
                            }
                        },
                    },
                    GlobalParameters = new Dictionary<string, string>()
                    {
                    }
                };
                Console.Write("Jason object created");
                Console.Write("Connecting to Werb service ======>");
                //string apiKey = "ujM1au5E4i0z9TZ79nf6GCWoI10Kzosjh9+ZxyIv838y5nl70cxuaxOEl2QTrjN+f5gqYU6l4XXmcSVuju/zGw=="; // Replace this with the API key for the web service
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", API);
                client.BaseAddress = new Uri(URL);
                // WARNING: The 'await' statement below can result in a deadlock
                // if you are calling this code from the UI thread of an ASP.Net application.
                // One way to address this would be to call ConfigureAwait(false)
                // so that the execution does not attempt to resume on the original context.
                // For instance, replace code such as:
                //      result = await DoSomeTask()
                // with the following:
                //      result = await DoSomeTask().ConfigureAwait(false)

                HttpResponseMessage response = client.PostAsJsonAsync("", scoreRequest).Result;
                string output = null;
                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine("Sending Request");
                    String result = response.Content.ReadAsStringAsync().Result;
                    // JObject responseData = JObject.Parse(result);
                    dynamic jsonData = JsonConvert.DeserializeObject<dynamic>(result);
                    output = jsonData.Results.output1[0]["Scored Labels"];
                    //txtResult.Text = cnic;
                    Console.WriteLine("Result: {0}", result);
                }
                else
                {
                    Console.WriteLine(string.Format("The request failed with status code: {0}", response.StatusCode));
                    // Print the headers - they include the requert ID and the timestamp,
                    // which are useful for debugging the failure
                    Console.WriteLine(response.Headers.ToString());

                    string responseContent = response.Content.ReadAsStringAsync().Result;
                    Console.WriteLine(responseContent);
                }
                return output;
            }
        }

        protected string RequestPrediction1(String API, String URL)
        {
            Console.Write("Forming Jason Object");
            using (var client = new HttpClient())
            {
                var scoreRequest = new
                {
                    Inputs = new Dictionary<string, List<Dictionary<string, string>>>() {
                        {
                            "input1",
                            new List<Dictionary<string, string>>(){new Dictionary<string, string>(){
                                            {
                                                "sub_grade", TextSubGradeChange.Text
                                            },
                                            {
                                                "loan_amnt", TextBox1.Text
                                            },
                                            {
                                                "Derived_term", TextBox7.Text
                                            },
                                            {
                                                "issue_year", TextBox11.Text
                                            },
                                            {
                                                "percent_bc_gt_75", TextBox10.Text
                                            },
                                            {
                                                "num_tl_op_past_12m", TextBox4.Text
                                            },
                                            {
                                                "mo_sin_rcnt_tl", TextBox8.Text
                                            },
                                            {
                                                "FicoScore", TextBox2.Text
                                            },
                                            {
                                                "addr_state", TextStateChange.Text
                                            },
                                            {
                                                "emp_length", TextBox3.Text
                                            },
                                            {
                                                "annual_inc", TextBox12.Text
                                            },
                                            {
                                                "delinq_2yrs", TextBox5.Text
                                            },
                                }
                            }
                        },
                    },
                    GlobalParameters = new Dictionary<string, string>()
                    {
                    }
                };
                Console.Write("Jason object created");
                Console.Write("Connecting to Werb service ======>");
                //string apiKey = "ujM1au5E4i0z9TZ79nf6GCWoI10Kzosjh9+ZxyIv838y5nl70cxuaxOEl2QTrjN+f5gqYU6l4XXmcSVuju/zGw=="; // Replace this with the API key for the web service
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", API);
                client.BaseAddress = new Uri(URL);
                // WARNING: The 'await' statement below can result in a deadlock
                // if you are calling this code from the UI thread of an ASP.Net application.
                // One way to address this would be to call ConfigureAwait(false)
                // so that the execution does not attempt to resume on the original context.
                // For instance, replace code such as:
                //      result = await DoSomeTask()
                // with the following:
                //      result = await DoSomeTask().ConfigureAwait(false)

                HttpResponseMessage response = client.PostAsJsonAsync("", scoreRequest).Result;
                string output = null;
                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine("Sending Request");
                    String result = response.Content.ReadAsStringAsync().Result;
                    // JObject responseData = JObject.Parse(result);
                    dynamic jsonData = JsonConvert.DeserializeObject<dynamic>(result);
                    output = jsonData.Results.output1[0]["Scored Labels"];
                    //txtResult.Text = cnic;
                    Console.WriteLine("Result: {0}", result);
                }
                else
                {
                    Console.WriteLine(string.Format("The request failed with status code: {0}", response.StatusCode));
                    // Print the headers - they include the requert ID and the timestamp,
                    // which are useful for debugging the failure
                    Console.WriteLine(response.Headers.ToString());

                    string responseContent = response.Content.ReadAsStringAsync().Result;
                    Console.WriteLine(responseContent);
                }
                return output;
            }
        }

        protected string RequestCluster(String API, String URL)
        {
            Console.Write("Forming Jason Object");
            using (var client = new HttpClient())
            {
                var scoreRequest = new
                {
                    Inputs = new Dictionary<string, List<Dictionary<string, string>>>() {
                        {
                            "input1",
                            new List<Dictionary<string, string>>(){new Dictionary<string, string>(){
                                            {
                                                "sub_grade", TextSubGradeChange.Text
                                            },
                                            {
                                                "loan_amnt", TextBox1.Text
                                            },
                                            {
                                                "Derived_term", TextBox7.Text
                                            },
                                            {
                                                "issue_year", TextBox11.Text
                                            },
                                            {
                                                "percent_bc_gt_75", TextBox10.Text
                                            },
                                            {
                                                "num_tl_op_past_12m", TextBox4.Text
                                            },
                                            {
                                                "mo_sin_rcnt_tl", TextBox8.Text
                                            },
                                            {
                                                "FicoScore", TextBox2.Text
                                            },
                                            {
                                                "addr_state", TextStateChange.Text
                                            },
                                            {
                                                "emp_length", TextBox3.Text
                                            },
                                            {
                                                "annual_inc", TextBox12.Text
                                            },
                                            {
                                                "delinq_2yrs", TextBox5.Text
                                            },
                                            {
                                                "int_rate", "1"
                                            },
                                }
                            }
                        },
                    },
                    GlobalParameters = new Dictionary<string, string>()
                    {
                    }
                };
                Console.Write("Jason object created");
                Console.Write("Connecting to Werb service ======>");
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", API);
                client.BaseAddress = new Uri(URL);
                // WARNING: The 'await' statement below can result in a deadlock
                // if you are calling this code from the UI thread of an ASP.Net application.
                // One way to address this would be to call ConfigureAwait(false)
                // so that the execution does not attempt to resume on the original context.
                // For instance, replace code such as:
                //      result = await DoSomeTask()
                // with the following:
                //      result = await DoSomeTask().ConfigureAwait(false)

                HttpResponseMessage response = client.PostAsJsonAsync("", scoreRequest).Result;
                string output = null;
                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine("Sending Request");
                    String result = response.Content.ReadAsStringAsync().Result;
                    // JObject responseData = JObject.Parse(result);
                    dynamic jsonData = JsonConvert.DeserializeObject<dynamic>(result);
                    output = jsonData.Results.output1[0]["Scored Labels"];
                    //txtResult.Text = cnic;
                    Console.WriteLine("Result: {0}", result);
                }
                else
                {
                    Console.WriteLine(string.Format("The request failed with status code: {0}", response.StatusCode));
                    // Print the headers - they include the requert ID and the timestamp,
                    // which are useful for debugging the failure
                    Console.WriteLine(response.Headers.ToString());

                    string responseContent = response.Content.ReadAsStringAsync().Result;
                    Console.WriteLine(responseContent);
                }
                return output;
            }
        }

        protected void TextBox3_TextChanged(object sender, EventArgs e)
        {

        }

        protected void Button4_Click(object sender, EventArgs e)
        {

        }
    }
}