CONVERT TEXT TO SPEECH ULTIMATE — ASP.NET WEB FORMS
Target framework: .NET Framework 4.8
Language: C#

OPEN / RUN
1. Extract the ZIP.
2. Open ConvertTextToSpeech.sln in Visual Studio 2022.
3. Install the “ASP.NET and web development” workload and .NET Framework 4.8 Developer Pack.
4. Set ConvertTextToSpeech as the startup project and press F5.

WEB FORMS CONVERSION NOTES
- Default.aspx is the Web Forms page and is hosted inside one server-side form.
- The main text editor and translation output are ASP.NET TextBox controls with static client IDs.
- JavaScript-driven buttons explicitly use type="button" to prevent unwanted Web Forms postbacks.
- Speech synthesis, microphone permissions, audio recording, browser voices and translation services remain browser-side features.
- Microphone APIs generally require HTTPS or localhost and user permission.

This project has been structurally updated for Web Forms, but a Windows Visual Studio build/runtime test was not available in this environment.
