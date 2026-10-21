using System;

namespace ConvertTextToSpeech
{
    /// <summary>
    /// ASP.NET Web Forms page for the Text-to-Speech application.
    /// Speech synthesis, voice selection, translation and recording remain in the browser,
    /// while the primary text fields are genuine Web Forms server controls.
    /// </summary>
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Preserve the stable DOM IDs used by the original JavaScript.
            // ClientIDMode="Static" ensures ASP.NET does not prepend naming-container IDs.
            text.Attributes["onscroll"] = "syncScroll('text', 'highlightLayer')";
            translateResult.Attributes["onscroll"] = "syncScroll('translateResult', 'highlightTranslateLayer')";

            // Avoid reinitializing the UI on postback; the page is primarily client-driven.
            if (!IsPostBack)
            {
                ViewState["ApplicationName"] = "Text To Speech Pro - Visualizer & Translator Ultimate";
            }
        }
    }
}
