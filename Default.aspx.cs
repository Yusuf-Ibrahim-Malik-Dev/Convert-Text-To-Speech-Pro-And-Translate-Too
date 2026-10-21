using System;
using System.Text;
using System.Web.UI;

namespace ConvertTextToSpeech
{
    /// <summary>
    /// Main Web Forms page. Speech, microphone, translation, and visualization
    /// remain browser-side and continue to use the original JavaScript libraries.
    /// </summary>
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Explicit UTF-8 response encoding helps browsers display Unicode correctly.
            Response.ContentEncoding = Encoding.UTF8;
            Response.Charset = "utf-8";
        }
    }
}
