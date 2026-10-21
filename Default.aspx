<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ConvertTextToSpeech.Default" %>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Text To Speech Pro - Visualizer & Translator Ultimate</title>
    <style>
        /* --- Reset & Core CSS Variables --- */
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif; 
        }

        :root {
            --bg-gradient: linear-gradient(135deg, #070714 0%, #12122b 50%, #070714 100%);
            --panel-bg: rgba(16, 16, 36, 0.8);
            --subpanel-bg: rgba(255, 255, 255, 0.02);
            --border-color: rgba(255, 255, 255, 0.08);
            --text-main: #f1edf7;
            --text-muted: #94a3b8;
            --primary: #8b5cf6;
            --primary-dark: #6d28d9;
            --accent-red: #ef4444;
            --accent-blue: #3b82f6;
            --accent-amber: #f59e0b;
            --accent-emerald: #10b981;
        }

        body {
            min-height: 100vh;
            background: var(--bg-gradient);
            display: flex; 
            flex-direction: column;
            justify-content: center; 
            align-items: center;
            overflow-x: hidden; 
            color: var(--text-main);
            transition: all 0.5s ease;
        }

        body::before {
            content: ''; 
            position: fixed; 
            top: 0; left: 0; right: 0; bottom: 0;
            background: radial-gradient(2px 2px at 20% 30%, rgba(255, 255, 255, 0.15), transparent),
                        radial-gradient(2px 2px at 40% 70%, rgba(255, 255, 255, 0.1), transparent),
                        radial-gradient(2px 2px at 60% 20%, rgba(255, 255, 255, 0.15), transparent),
                        radial-gradient(2px 2px at 80% 80%, rgba(255, 255, 255, 0.1), transparent);
            background-size: 250px 250px; 
            animation: twinkle 4s ease-in-out infinite alternate; 
            pointer-events: none; 
            z-index: 0;
        }

        @keyframes twinkle { 0% { opacity: 0.4; } 100% { opacity: 1; } }

        /* --- Layout Mode Switcher Panel --- */
        .layout-switcher {
            display: flex;
            gap: 20px;
            background: rgba(0, 0, 0, 0.4);
            padding: 10px 20px;
            border-radius: 30px;
            margin-bottom: 20px;
            border: 1px solid var(--border-color);
            z-index: 10;
        }
        .layout-checkbox-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            user-select: none;
        }
        .layout-checkbox-label input[type="checkbox"] {
            appearance: none;
            width: 16px;
            height: 16px;
            border: 2px solid var(--border-color);
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.05);
            cursor: pointer;
            position: relative;
            transition: all 0.2s;
        }
        .layout-checkbox-label input[type="checkbox"]:checked {
            background: var(--primary);
            border-color: var(--primary);
        }
        .layout-checkbox-label input[type="checkbox"]:checked::after {
            content: '✓';
            position: absolute;
            color: white;
            font-size: 11px;
            top: -2px;
            left: 2px;
            font-weight: bold;
        }
        .layout-checkbox-label input[type="checkbox"]:checked + span {
            color: var(--text-main);
        }

        /* --- Main Container --- */
        .container {
            width: 100%;
            max-width: 960px; 
            background: var(--panel-bg);
            backdrop-filter: blur(24px); 
            -webkit-backdrop-filter: blur(24px);
            border-radius: 24px; 
            box-shadow: 0 40px 100px rgba(0, 0, 0, 0.65), inset 0 1px 1px rgba(255, 255, 255, 0.05);
            padding: 40px; 
            position: relative; 
            z-index: 1; 
            border: 1px solid var(--border-color);
            transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* --- ANDROID MODE OVERRIDES --- */
        body.mode-android .container {
            max-width: 410px;
            border-radius: 40px;
            padding: 30px 20px;
            border: 6px solid #2d2d44; /* Bingkai Ponsel */
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.8);
            background: rgba(12, 12, 28, 0.95);
        }
        body.mode-android .row, 
        body.mode-android .row.three, 
        body.mode-android .translate-top-row, 
        body.mode-android .exp-grid { 
            grid-template-columns: 1fr; 
            gap: 14px; 
        }
        body.mode-android .translate-buttons { width: 100%; }
        body.mode-android .translate-buttons button { flex: 1; justify-content: center; }
        body.mode-android #liveSubtitleText { font-size: 22px; }
        body.mode-android .buttons { flex-direction: column; }
        body.mode-android .buttons button { width: 100%; justify-content: center; }
        body.mode-android .floating-controls { width: 95%; justify-content: center; bottom: 8px; }
        body.mode-android .exp-card .btn-exp { width: 100%; justify-content: center; }

        /* --- Header Section --- */
        .header { 
            display: flex; 
            align-items: center; 
            justify-content: space-between; 
            margin-bottom: 25px; 
            padding-bottom: 20px; 
            border-bottom: 1px solid var(--border-color); 
            flex-wrap: wrap; 
            gap: 15px; 
        }
        
        h2 { 
            font-size: 24px; 
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #c084fc 0%, #a855f7 50%, #7e22ce 100%); 
            -webkit-background-clip: text; 
            -webkit-text-fill-color: transparent; 
            display: flex; 
            align-items: center; 
            gap: 12px; 
        }

        label { 
            font-weight: 600; 
            display: block; 
            margin-top: 14px; 
            margin-bottom: 8px; 
            color: #cbd5e1; 
            font-size: 11.5px; 
            letter-spacing: 0.75px;
            text-transform: uppercase; 
        }

        /* --- Panels & Modules --- */
        .sub-panel {
            background: var(--subpanel-bg);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 20px;
            margin-top: 20px;
        }
        
        .sub-panel-title {
            font-size: 13px;
            font-weight: 700;
            color: #c084fc;
            text-transform: uppercase;
            margin-bottom: 14px;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* --- Wave Visualizer --- */
        .wave-visualizer {
            width: 100%; 
            height: 140px; 
            background: rgba(0, 0, 0, 0.4); 
            border-radius: 16px; 
            margin-bottom: 25px;
            overflow: hidden; 
            position: relative; 
            border: 1px solid var(--border-color); 
            display: flex; 
            align-items: center; 
            justify-content: center;
        }
        .wave-visualizer canvas { width: 100%; height: 100%; display: block; }
        .wave-overlay-text { 
            position: absolute; 
            color: rgba(255, 255, 255, 0.04); 
            font-size: 11px; 
            letter-spacing: 6px; 
            text-transform: uppercase; 
            pointer-events: none; 
            font-weight: 700;
        }

        /* --- Interactive Editors framework --- */
        .text-wrapper { 
            position: relative; 
            border-radius: 14px; 
            background: rgba(0, 0, 0, 0.35); 
            border: 1px solid var(--border-color); 
            overflow: hidden; 
            transition: all 0.25s;
        }
        .text-wrapper:focus-within { 
            border-color: rgba(239, 68, 68, 0.5); 
            box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.1); 
        }
        
        textarea { 
            width: 100%; 
            resize: none; 
            padding: 18px; 
            border: none; 
            font-size: 15px; 
            line-height: 1.7; 
            background: transparent; 
            color: var(--text-main); 
            position: relative; 
            z-index: 2; 
            outline: none; 
        }
        #text { height: 130px; } 
        #translateResult { height: 110px; }
        
        .highlight-layer { 
            position: absolute; 
            top: 0; left: 0; 
            width: 100%; height: 100%; 
            pointer-events: none; 
            z-index: 1; 
            padding: 18px; 
            font-size: 15px; 
            line-height: 1.7; 
            color: transparent; 
            white-space: pre-wrap; 
            word-wrap: break-word; 
            overflow-y: auto; 
            overflow-x: hidden;
        }
        
        .word-mark { background: transparent; border-radius: 4px; transition: background-color 0.1s ease; display: inline-block; }
        #highlightLayer .word-mark.active { background-color: rgba(239, 68, 68, 0.35); box-shadow: 0 0 8px rgba(239, 68, 68, 0.4); color: #fff; }
        #highlightTranslateLayer .word-mark.active { background-color: rgba(59, 130, 246, 0.35); box-shadow: 0 0 8px rgba(59, 130, 246, 0.4); color: #fff; }

        .character-count { display: flex; justify-content: flex-end; font-size: 12px; color: var(--text-muted); margin-top: 8px; }
        .character-count .count { color: #c084fc; font-weight: 600; }

        /* --- Translation Framework --- */
        .translate-section { margin-top: 25px; padding-top: 25px; border-top: 1px solid var(--border-color); }
        .translate-top-row { display: grid; grid-template-columns: 1fr auto; gap: 16px; align-items: end; }
        .translate-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        
        /* --- Buttons Design --- */
        button { 
            padding: 11px 20px; 
            border-radius: 10px; 
            border: none; 
            font-weight: 600; 
            font-size: 13px; 
            cursor: pointer; 
            display: flex; 
            align-items: center; 
            gap: 8px; 
            color: white; 
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1); 
        }
        button:hover { transform: translateY(-1px); filter: brightness(1.1); box-shadow: 0 6px 20px rgba(0,0,0,0.3); }
        button:active { transform: translateY(1px); }
        button:disabled { opacity: 0.25; cursor: not-allowed; transform: none; box-shadow: none; filter: none; }
        
        #translateBtn { background: linear-gradient(135deg, var(--primary), var(--primary-dark)); }
        #clearTranslateBtn { background: #334155; color: #cbd5e1; }
        #playTranslate { background: linear-gradient(135deg, var(--accent-blue), #1d4ed8); }
        #stopTranslate { background: linear-gradient(135deg, var(--accent-red), #b91c1c); }

        /* --- Parallel Phrases Section --- */
        .parallel-wrapper { 
            border-radius: 14px; 
            background: rgba(0, 0, 0, 0.25); 
            padding: 16px; 
            min-height: 80px; 
            display: flex; 
            flex-direction: column; 
            gap: 10px; 
            border: 1px solid var(--border-color); 
            max-height: 250px; 
            overflow-y: auto;
        }
        .phrase-pair { 
            display: flex; 
            flex-direction: column; 
            gap: 6px; 
            padding: 12px 16px; 
            border-radius: 10px; 
            background: rgba(255, 255, 255, 0.02); 
            transition: all 0.25s ease; 
            border: 1px solid transparent; 
        }
        
        .phrase-pair.active-phrase { background: rgba(239, 68, 68, 0.08); border-color: rgba(239, 68, 68, 0.25); transform: translateX(4px); }
        .phrase-pair.active-phrase-trans { background: rgba(59, 130, 246, 0.08); border-color: rgba(59, 130, 246, 0.25); transform: translateX(4px); }

        .parallel-text { font-size: 14.5px; line-height: 1.6; }
        .orig-text { color: #f87171; font-weight: 500; }
        .trans-text { color: #60a5fa; font-weight: 500; border-top: 1px dashed rgba(255,255,255,0.06); padding-top: 6px; margin-top: 2px; }
        
        .parallel-text span { transition: all 0.15s ease; border-radius: 3px; padding: 0 2px; display: inline-block; }
        .orig-text span.active { background-color: var(--accent-red); color: #fff; box-shadow: 0 0 8px rgba(239, 68, 68, 0.6); }
        .trans-text span.active { background-color: var(--accent-blue); color: #fff; box-shadow: 0 0 8px rgba(59, 130, 246, 0.6); }

        /* --- UI Switches Container --- */
        .switch-container {
            display: flex; align-items: center; justify-content: center; gap: 12px; margin-top: 25px;
        }
        .switch-label {
            font-size: 12px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px;
        }
        .toggle-switch {
            position: relative; display: inline-block; width: 42px; height: 22px;
        }
        .toggle-switch input { opacity: 0; width: 0; height: 0; }
        .slider {
            position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0;
            background-color: #334155; transition: .3s; border-radius: 24px;
        }
        .slider:before {
            position: absolute; content: ""; height: 16px; width: 16px; left: 3px; bottom: 3px;
            background-color: white; transition: .3s; border-radius: 50%;
        }
        input:checked + .slider { background-color: var(--accent-red); box-shadow: 0 0 10px rgba(239, 68, 68, 0.4); }
        input:checked + .slider:before { transform: translateX(20px); }

        /* --- Live Subtitles Teleprompter --- */
        .live-subtitle-container { 
            margin-top: 12px; 
            background: rgba(0, 0, 0, 0.4); 
            border: 1.5px dashed rgba(239, 68, 68, 0.4); 
            border-radius: 16px; 
            padding: 20px; 
            text-align: center; 
            transition: all 0.3s ease; 
            height: 120px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            position: relative; 
            overflow-y: auto;
        }
        .live-subtitle-container.active-orig { border-style: solid; border-color: var(--accent-red); box-shadow: 0 0 30px rgba(239, 68, 68, 0.15); background: rgba(239, 68, 68, 0.03); }
        .live-subtitle-container.active-trans { border-style: solid; border-color: var(--accent-blue); box-shadow: 0 0 30px rgba(59, 130, 246, 0.15); background: rgba(59, 130, 246, 0.03); }
        
        #liveSubtitleText { font-size: 32px; font-weight: 800; color: white; text-shadow: 0 2px 10px rgba(0,0,0,0.5); letter-spacing: -0.5px; transition: all 0.3s; width: 100%; word-wrap: break-word; }
        .live-subtitle-container.active-orig #liveSubtitleText { text-shadow: 0 0 15px rgba(239, 68, 68, 0.6); }
        .live-subtitle-container.active-trans #liveSubtitleText { text-shadow: 0 0 15px rgba(59, 130, 246, 0.6); }

        .floating-controls-outer {
            display: flex; justify-content: center; width: 100%; margin-top: 16px; height: 40px;
        }
        .floating-controls {
            background: rgba(10, 10, 25, 0.9); backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.12); border-radius: 30px;
            padding: 5px 12px; display: flex; gap: 6px; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            opacity: 0; pointer-events: none; transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); z-index: 100;
            transform: translateY(10px);
        }
        .floating-controls.show { opacity: 1; pointer-events: auto; transform: translateY(0); }
        .floating-controls button { padding: 6px 14px; font-size: 11px; border-radius: 20px; font-weight: 700; }
        .floating-controls .btn-pause { background: var(--accent-amber); color: #000; }
        .floating-controls .btn-resume { background: var(--accent-emerald); }
        .floating-controls .btn-stop { background: var(--accent-red); }

        /* --- Input Custom Controls --- */
        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 12px; }
        .row.three { grid-template-columns: 1fr 1fr 1fr; }
        
        select { 
            width: 100%; 
            height: 42px; 
            border: 1px solid var(--border-color); 
            border-radius: 10px; 
            padding: 0 14px; 
            background: rgba(0,0,0,0.3); 
            color: var(--text-main); 
            appearance: none; 
            cursor: pointer; 
            font-size: 13px;
            outline: none;
            transition: border 0.2s;
        }
        select option { background: #161630; color: #fff; }
        select:focus { border-color: var(--primary); }
        
        input[type="range"] { 
            -webkit-appearance: none; 
            width: 100%; 
            height: 6px; 
            border-radius: 4px; 
            background: #334155; 
            outline: none; 
            margin-top: 8px;
        }
        input[type="range"]::-webkit-slider-thumb { 
            -webkit-appearance: none; 
            width: 18px; 
            height: 18px; 
            border-radius: 50%; 
            background: var(--primary); 
            cursor: pointer; 
            transition: transform 0.1s;
        }
        input[type="range"]::-webkit-slider-thumb:hover { transform: scale(1.2); }

        .slider-val { font-size: 11px; color: #c084fc; float: right; font-weight: 600; }
        .efek-khusus { background: rgba(245, 158, 11, 0.05) !important; border-color: rgba(245, 158, 11, 0.2) !important; color: #f59e0b !important; }

        /* --- Main Operational Buttons --- */
        .buttons { display: flex; justify-content: center; gap: 12px; margin-top: 35px; }
        #play { background: linear-gradient(135deg, var(--primary), var(--primary-dark)); padding: 14px 35px; font-size: 15px; border-radius: 12px; }
        #play.speaking { background: linear-gradient(135deg, var(--accent-red), #b91c1c); animation: pulseRed 1.5s infinite alternate; }
        @keyframes pulseRed { 0% { box-shadow: 0 0 15px rgba(239, 68, 68, 0.3); } 100% { box-shadow: 0 0 35px rgba(239, 68, 68, 0.6); } }
        
        #pause { background: var(--accent-amber); color: #000; }
        #resume { background: var(--accent-emerald); }
        #stop { background: #334155; }

        /* --- Sub-Panels (Experimental & Lab Suite) --- */
        .experimental-panel {
            margin-top: 30px; padding: 20px; border-radius: 18px;
            background: var(--subpanel-bg); border: 1px dashed rgba(167, 139, 250, 0.3);
        }
        .experimental-panel h3 { font-size: 15px; color: #c084fc; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; font-weight: 700; }
        .exp-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .exp-card { background: rgba(0, 0, 0, 0.25); padding: 16px; border-radius: 12px; border: 1px solid rgba(255,255,255,0.02); display: flex; flex-direction: column; justify-content: space-between; gap: 10px; }
        .exp-card p { font-size: 12px; color: var(--text-muted); line-height: 1.5; margin-bottom: 4px; }
        .btn-exp { font-size: 11.5px; padding: 8px 14px; border-radius: 8px; font-weight: 600; width: fit-content; }
        #btnResponsive { background: linear-gradient(135deg, #ec4899, #be185d); }
        #btnListen { background: linear-gradient(135deg, #06b6d4, #0891b2); }

        .ai-studio-panel {
            margin-top: 25px; padding: 20px; border-radius: 18px;
            background: rgba(15, 23, 42, 0.4); border: 1px solid rgba(16, 185, 129, 0.2);
        }
        .ai-studio-panel h3 { font-size: 15px; color: var(--accent-emerald); margin-bottom: 12px; display: flex; align-items: center; gap: 8px; font-weight: 700; }
        #btnRecord { background: linear-gradient(135deg, #10b981, #047857); }
        #btnDownloadRec { background: linear-gradient(135deg, var(--accent-amber), #b45309); color: #000; font-weight: 700; }
        #btnONNX { background: linear-gradient(135deg, #6366f1, #4338ca); }

        /* --- Status Bar --- */
        .status { 
            margin-top: 25px; 
            text-align: center; 
            font-weight: 600; 
            padding: 12px; 
            border-radius: 10px; 
            background: rgba(0,0,0,0.2); 
            font-size: 13px;
            border: 1px solid rgba(255,255,255,0.02);
            color: var(--text-muted);
        }
        .status-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 8px; background: var(--accent-emerald); }
        .status.speaking .status-dot { background: var(--accent-red); animation: blink 0.6s infinite alternate; }
        .status.speaking-trans .status-dot { background: var(--accent-blue); animation: blink 0.6s infinite alternate; }
        @keyframes blink { from { opacity: 0.4; } to { opacity: 1; } }

        /* --- Scrollbar --- */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: rgba(0,0,0,0.1); }
        ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.12); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--primary); }

        @media (max-width: 768px) {
            .container { padding: 20px; }
            .row, .row.three, .translate-top-row, .exp-grid { grid-template-columns: 1fr; gap: 14px; }
            .translate-buttons { width: 100%; }
            .translate-buttons button { flex: 1; justify-content: center; }
            #liveSubtitleText { font-size: 24px; }
            .buttons { flex-direction: column; }
            .buttons button { width: 100%; justify-content: center; }
            .floating-controls { width: 90%; justify-content: center; }
            .exp-card .btn-exp { width: 100%; justify-content: center; }
        }

        
/* =======================================
   ROOT_NAMA CLASS_YUSUF STYLING
   ======================================= */
.yusuf-footer {
    background-color: #0c1622; /* Footer cerah */
    padding: 40px 0;
    width: 100%;
    border-top: 2px solid #1b263b;
    position: relative;
    z-index: 10;
    overflow: hidden;
    transition: background-color 0.8s ease, border-color 0.8s ease;
}

body.yusuf-storm-active .yusuf-footer {
    background-color: #020304; /* Footer saat badai */
    border-top-color: #11141a;
}

.yusuf-footer-container {
    position: relative;
    max-width: 1200px;
    margin: 0 auto;
    text-align: center;
    z-index: 12;
}

.yusuf-copyright-text {
    color: #8da9c4;
    font-size: 1rem;
    letter-spacing: 1px;
    transition: color 0.8s ease;
}

body.yusuf-storm-active .yusuf-copyright-text {
    color: #5f6470;
}

.yusuf-storm-trigger {
    color: #e0e1dd; /* Warna text awal saat cerah */
    text-decoration: none;
    font-weight: bold;
    position: relative;
    transition: color 0.4s ease, text-shadow 0.4s ease;
    display: inline-block;
}

.yusuf-storm-trigger:hover {
    color: #00fff2;
}

/* EFEK KILATAN FLASH DI TANAH */
.yusuf-ground-flash {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: radial-gradient(ellipse at top, rgba(0, 255, 242, 0.4) 0%, transparent 70%);
    opacity: 0;
    z-index: 11;
    pointer-events: none;
}
.yusuf-ground-flash.flash-active {
    animation: flashGround 0.25s ease-out forwards;
}

@keyframes flashGround {
    0%, 100% { opacity: 0; }
    20%, 60% { opacity: 1; }
}

/* RETAKAN TANAH */
.yusuf-ground-cracks {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: #00fff2;
    opacity: 0;
    z-index: 11;
    pointer-events: none;
    filter: blur(0.5px) drop-shadow(0 0 8px #00fff2);
    clip-path: polygon(
        45% 0%, 47% 15%, 43% 30%, 48% 50%, 42% 70%, 46% 100%, 
        45% 100%, 41% 72%, 46% 51%, 41% 32%, 45% 16%, 44% 0%,
        /* Cabang Kiri */
        43% 30%, 35% 45%, 38% 65%, 30% 85%, 31% 85%, 39% 64%, 36% 46%,
        /* Cabang Kanan */
        48% 50%, 58% 65%, 54% 85%, 65% 100%, 64% 100%, 53% 86%, 57% 66%
    );
}

.yusuf-ground-cracks.cracks-active {
    animation: crackGlow 0.4s ease-out forwards;
}

@keyframes crackGlow {
    0% { opacity: 0; filter: brightness(0.5) blur(1px); }
    15%, 45% { opacity: 1; filter: brightness(2) blur(0px); }
    100% { opacity: 0; filter: brightness(0.2) blur(2px); }
}

/* =======================================
   WADAH ANIMASI BADAI (HIDDEN BY DEFAULT)
   ======================================= */
.yusuf-storm-wrapper {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
    z-index: 5;
    opacity: 0;
    transition: opacity 0.8s ease;
}

.yusuf-storm-wrapper.active {
    opacity: 1;
}

.yusuf-storm-wrapper.ambient-flash {
    animation: skyFlash 0.3s ease-out;
}

@keyframes skyFlash {
    0%, 100% { background-color: transparent; }
    25%, 65% { background-color: rgba(255, 255, 255, 0.15); }
}

/* AWAN BERJALAN */
.yusuf-cloud-container {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 250px;
    overflow: hidden;
}

.yusuf-cloud-layer {
    position: absolute;
    width: 200%;
    height: 100%;
    background: repeat-x url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 100 100'%3E%3Cpath d='M10 80 C 20 60, 40 60, 50 70 C 60 50, 80 50, 90 75 C 95 65, 105 70, 100 85 Z' fill='%23181d26' opacity='0.85'/%3E%3C/svg%3E");
    background-size: 300px 150px;
    filter: blur(8px);
}

.yusuf-cloud-1 {
    top: -20px;
    animation: moveClouds 40s linear infinite;
}

.yusuf-cloud-2 {
    top: 10px;
    background-size: 450px 200px;
    opacity: 0.6;
    animation: moveClouds 25s linear infinite reverse;
}

@keyframes moveClouds {
    0% { transform: translateX(0); }
    100% { transform: translateX(-50%); }
}

/* HUJAN */
.yusuf-rain-container {
    position: absolute;
    top: 120px;
    left: 0;
    width: 100%;
    height: 100%;
}

.yusuf-drop {
    position: absolute;
    background: linear-gradient(transparent, rgba(0, 255, 242, 0.4));
    width: 1.2px;
    height: 30px;
    animation: fall 0.6s linear infinite;
}

@keyframes fall {
    0% { transform: translateY(-50px) rotate(15deg); }
    100% { transform: translateY(100vh) rotate(15deg); }
}

/* CANVAS PETIR */
.yusuf-lightning-canvas {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}

/* EFEK GEMPA */
.shake-body {
    animation: hardShake 0.15s linear 2;
}

@keyframes hardShake {
    0% { transform: translate(2px, 1px) rotate(0deg); }
    50% { transform: translate(-2px, -3px) rotate(-0.1deg); }
    100% { transform: translate(1px, 2px) rotate(0.1deg); }
}

 /* --- CLASS CUSTOM --- */
        .root_nama {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            display: inline-block;
            z-index: 1000;
        }

        .clas_yusuf {
            background-color: #1e3a8a;
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            cursor: pointer;
            font-weight: bold;
            font-family: 'Poppins', sans-serif;
            position: relative;
            z-index: 1010;
            transition: background 0.2s, transform 0.1s;
            box-shadow: 0 4px 15px rgba(30, 58, 138, 0.4);
        }

        .clas_yusuf:active {
            transform: scale(0.95);
        }

        /* --- CONTAINER HUJAN UANG FULL SCREEN --- */
        #moneyRainContainer {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            pointer-events: none;
            z-index: 999;
            overflow: hidden;
            display: none;
        }

        .money-item {
            position: absolute;
            top: -50px;
            pointer-events: none;
            user-select: none;
        }

        .bill-animation { animation: fallAndWave 3.5s ease-in-out infinite; }
        .coin-animation { animation: fallAndSpinCoin 2.8s linear infinite; }

        @keyframes fallAndWave {
            0% { transform: translateY(0) translateX(0) rotate(0deg); opacity: 1; }
            25% { transform: translateY(25vh) translateX(25px) rotate(12deg); }
            50% { transform: translateY(50vh) translateX(-25px) rotate(-12deg); }
            75% { transform: translateY(75vh) translateX(15px) rotate(8deg); }
            100% { transform: translateY(105vh) translateX(-5px) rotate(0deg); opacity: 0.3; }
        }

        @keyframes fallAndSpinCoin {
            0% { transform: translateY(0) rotateY(0deg); opacity: 1; }
            100% { transform: translateY(105vh) rotateY(540deg); opacity: 0.4; }
        }

        /* --- SCENE UTAMA (Awan, Matahari, Canvas) --- */
        #skyScene {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            pointer-events: none;
            z-index: 996;
            display: none;
        }

        .fancy-cloud {
            position: absolute;
            top: 2.5rem;
            left: 2.5rem;
            width: 160px;
            height: 55px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 50px;
            filter: drop-shadow(0 8px 15px rgba(0,0,0,0.1));
            animation: floatCloud 4s ease-in-out infinite alternate;
            z-index: 998;
        }
        .fancy-cloud::before, .fancy-cloud::after {
            content: '';
            position: absolute;
            background: inherit;
            border-radius: 50%;
        }
        .fancy-cloud::before { width: 75px; height: 75px; top: -38px; left: 25px; }
        .fancy-cloud::after { width: 95px; height: 95px; top: -55px; left: 55px; }

        .bright-sun {
            position: absolute;
            top: 1.5rem;
            left: 4.5rem;
            width: 85px;
            height: 85px;
            background: radial-gradient(circle, #fff385 0%, #f6e05e 100%);
            border-radius: 50%;
            box-shadow: 0 0 50px rgba(246, 224, 94, 0.7);
            z-index: 997;
            animation: sunPulse 3s ease-in-out infinite;
        }

        @keyframes floatCloud { 0% { transform: translateY(0); } 100% { transform: translateY(-8px); } }
        @keyframes sunPulse { 0%, 100% { transform: scale(1); opacity: 0.85; } 50% { transform: scale(1.06); opacity: 1; box-shadow: 0 0 65px rgba(246, 224, 94, 0.9); } }

        #rainbowCanvas {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: 996;
            pointer-events: none;
        }
    </style>
    
    <!-- ORIGINAL PACKED LIBRARIES (LOKAL) -->
    <script src="assets/js/Translator.js"></script>
    <script src="assets/js/artyom.min.js"></script>
    <script src="assets/js/annyang.min.js"></script>
    <script src="assets/js/speakClient.js"></script>
    <script src="assets/js/mespeak.js"></script>
    <script src="assets/js/voice-ui.umd.min.js"></script>
    <script src="assets/js/EasySpeech.iife.js"></script>
    <script src="assets/js/responsivevoice.js"></script>

    <!-- INTEGRATION LIBRARIES (LOKAL) -->
    <script src="assets/js/ort.min.js"></script>
    <script src="assets/js/speak-tts.min.js"></script>
    <script src="assets/js/speechkitt.min.js"></script>
    <script src="assets/js/RecordRTC.js"></script>
    <script src="assets/js/recorder.min.js"></script>
    <script src="assets/js/audio-recorder-polyfill.js"></script>
</head>
<body>

    <!-- ADDITION: LAYOUT CONTROLLER SWITCH VIEW PANEL -->
    <div class="layout-switcher">
        <label class="layout-checkbox-label">
            <input type="checkbox" id="chkDesktop" checked>
            <span>🖥️ View Desktop</span>
        </label>
        <label class="layout-checkbox-label">
            <input type="checkbox" id="chkAndroid">
            <span>📱 View Android</span>
        </label>
    </div>

    <div class="container">
        <div class="header">
            <h2><span class="icon">🎵</span> Text To Speech & Translate Pro</h2>
            <div style="font-size:10px; color:var(--text-muted); letter-spacing:2px; text-align: right; line-height: 1.5;">
                🌐 ALL LANGUAGES<br>🤖 DUAL SYNC + ROBOT FX
            </div>
        </div>

        <div class="wave-visualizer">
            <canvas id="waveCanvas"></canvas>
            <div class="wave-overlay-text">~ Gelombang Suara Dinamis ~</div>
        </div>

        <label for="text">📝 Masukkan Teks (Teks Ini Akan Diblok Merah Mengikuti Suara)</label>
        <div class="text-wrapper">
            <textarea id="text" placeholder="Tulis atau tempel teks di sini..." onscroll="syncScroll('text', 'highlightLayer')">Selamat datang di sistem Text to Speech super pintar. Gelombang visualizer ini akan berdenyut secara nyata setiap kali sebuah kata diucapkan!</textarea>
            <div class="highlight-layer" id="highlightLayer"></div>
        </div>
        <div class="character-count">
            <span>Karakter: <span class="count" id="charCount">0</span></span>
        </div>

        <!-- AUDIO ENGINE CONTROLS FOR ORIGINAL TEXT -->
        <div class="sub-panel">
            <div class="sub-panel-title">🔊 Kontrol Audio Suara Asli (Original Voice Controls)</div>
            <div class="row">
                <div><label>🌐 Bahasa Suara</label><select id="language"></select></div>
                <div><label>🎙️ Pilih Suara Asli</label><select id="voice"></select></div>
            </div>
            <div class="row three">
                <div><label>⚡ Kecepatan <span class="slider-val" id="rateVal">1.0x</span></label><input type="range" id="rate" min="0.1" max="3.5" value="1.0" step="0.05" oninput="document.getElementById('rateVal').innerText=this.value+'x'"></div>
                <div><label>🎵 Nada (Pitch) <span class="slider-val" id="pitchVal">1.0</span></label><input type="range" id="pitch" min="0" max="2" value="1" step="0.1" oninput="document.getElementById('pitchVal').innerText=this.value"></div>
                <div><label>🔊 Volume <span class="slider-val" id="volumeVal">1.0</span></label><input type="range" id="volume" min="0" max="1" value="1" step="0.1" oninput="document.getElementById('volumeVal').innerText=this.value"></div>
            </div>
            <div class="row">
                <div style="grid-column: span 2;">
                    <label>🤖 EFEK SUARA ROBOT / CUSTOM (ASLI)</label>
                    <select id="robotEffect" class="efek-khusus">
                        <option value="none">❌ Tanpa Efek (Gunakan Slider Normal)</option>
                        <option value="cyborg">🦾 Cyborg (Kaku & Sedikit Berat)</option>
                        <option value="robot_deep">🤖 Robot Raksasa (Sangat Berat & Lambat)</option>
                        <option value="alien">👽 Alien (Melengking & Tidak Wajar)</option>
                        <option value="chipmunk">🐿️ Chipmunk (Super Cepat & Tinggi)</option>
                        <option value="slow">🐌 Siput (Slow Motion Ekstrim)</option>
                        <option value="fast">⚡ Kilat (Kecepatan 2x Lipat)</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="translate-section">
            <label>🌐 Terjemahkan ke Semua Bahasa (Akurasi 100%)</label>
            <div class="translate-top-row">
                <select id="translateLang"></select>
                <div class="translate-buttons">
                    <button id="translateBtn">🔄 Terjemahkan</button>
                    <button id="clearTranslateBtn">🗑️ Bersihkan</button>
                    <button id="playTranslate" disabled>🔊 Putar Terjemahan</button>
                    <button id="stopTranslate" disabled>⏹ Stop</button>
                </div>
            </div>
            <div class="text-wrapper" style="margin-top: 12px;">
                <textarea id="translateResult" placeholder="Hasil terjemahan akan muncul di sini..." readonly onscroll="syncScroll('translateResult', 'highlightTranslateLayer')"></textarea>
                <div class="highlight-layer" id="highlightTranslateLayer"></div>
            </div>
            <div id="translateStatus" style="font-size: 12px; color: #c084fc; margin-top: 8px;">💡 Pilih bahasa dan klik terjemahkan...</div>
        </div>

        <!-- AUDIO ENGINE CONTROLS FOR TRANSLATION TEXT -->
        <div class="sub-panel">
            <div class="sub-panel-title">🌐 Kontrol Audio Terjemahan (Translation Voice Controls)</div>
            <div class="row three">
                <div><label>⚡ Kecepatan Terjemahan <span class="slider-val" id="transRateVal">1.0x</span></label><input type="range" id="transRate" min="0.1" max="3.5" value="1.0" step="0.05" oninput="document.getElementById('transRateVal').innerText=this.value+'x'"></div>
                <div><label>🎵 Nada Terjemahan (Pitch) <span class="slider-val" id="transPitchVal">1.0</span></label><input type="range" id="transPitch" min="0" max="2" value="1" step="0.1" oninput="document.getElementById('transPitchVal').innerText=this.value"></div>
                <div><label>🔊 Volume Terjemahan <span class="slider-val" id="transVolumeVal">1.0</span></label><input type="range" id="transVolume" min="0" max="1" value="1" step="0.1" oninput="document.getElementById('transVolumeVal').innerText=this.value"></div>
            </div>
            <div class="row">
                <div style="grid-column: span 2;">
                    <label>🤖 EFEK SUARA ROBOT / CUSTOM (TERJEMAHAN)</label>
                    <select id="transRobotEffect" class="efek-khusus">
                        <option value="none">❌ Tanpa Efek (Gunakan Slider Normal)</option>
                        <option value="cyborg">🦾 Cyborg (Kaku & Sedikit Berat)</option>
                        <option value="robot_deep">🤖 Robot Raksasa (Sangat Berat & Lambat)</option>
                        <option value="alien">👽 Alien (Melengking & Tidak Wajar)</option>
                        <option value="chipmunk">🐿️ Chipmunk (Super Cepat & Tinggi)</option>
                        <option value="slow">🐌 Siput (Slow Motion Ekstrim)</option>
                        <option value="fast">⚡ Kilat (Kecepatan 2x Lipat)</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="parallel-section" style="margin-top: 25px;">
            <label>🔀 Frasa & Terjemahan (Sinkronisasi Blok Kalimat & Kata)</label>
            <div class="parallel-wrapper" id="parallelWrapper">
                <span style="color:rgba(255,255,255,0.25); font-style: italic; font-size: 13px;">Data frasa per-kata akan terbentuk otomatis setelah Anda menerjemahkan...</span>
            </div>
        </div>

        <div class="buttons">
            <button id="play">▶ Speak Original</button>
            <button id="pause">⏸ Pause</button>
            <button id="resume">▶ Resume</button>
            <button id="stop">⏹ Stop Semua</button>
        </div>

        <div class="switch-container">
            <span class="switch-label">Auto Focus Teks</span>
            <label class="toggle-switch">
                <input type="checkbox" id="autoFocusSwitch" checked>
                <span class="slider"></span>
            </label>
        </div>

        <label style="text-align: center; margin-top: 25px; color: var(--text-main); font-size: 12px; letter-spacing: 2px;">🎙️ KATA YANG SEDANG DIBACA</label>
        <div class="live-subtitle-container" id="liveSubtitleBox">
            <div id="liveSubtitleText">...</div>
        </div>

        <div class="floating-controls-outer">
            <div class="floating-controls" id="floatingControls">
                <button class="btn-pause" id="floatPause">⏸ Pause</button>
                <button class="btn-resume" id="floatResume">▶ Resume</button>
                <button class="btn-stop" id="floatStop">⏹ Stop</button>
            </div>
        </div>

        <!-- RECENT EXPERIMENTAL PANEL -->
        <div class="experimental-panel">
            <h3>🛠️ Extra Ultimate Tools Panel (Multi-Library Powered)</h3>
            <div class="exp-grid">
                <div class="exp-card">
                    <div>
                        <label style="margin:0 0 6px 0;">🔊 Engine Cadangan: ResponsiveVoice</label>
                        <p>Gunakan mesin cloud eksternal berkualitas HD jika browser Anda bermasalah dengan modul internal.</p>
                    </div>
                    <button id="btnResponsive" class="btn-exp">▶ Putar via ResponsiveVoice</button>
                </div>
                <div class="exp-card">
                    <div>
                        <label style="margin:0 0 6px 0;">🎙️ Asisten Pendengar: Annyang & Artyom</label>
                        <p>Aktifkan pendeteksi suara mikrofon untuk mengubah input suara ucapan Anda menjadi tulisan teks.</p>
                    </div>
                    <button id="btnListen" class="btn-exp">🎙️ Mulai Dikte Suara</button>
                </div>
            </div>
        </div>

        <!-- BRAND NEW ADDITION: AI ENGINE & STUDIO RECORD PANEL -->
        <div class="ai-studio-panel">
            <h3>🤖 AI Engine & Studio Record Pro (ONNX & RecordRTC)</h3>
            <div class="exp-grid">
                <div class="exp-card">
                    <div>
                        <label style="margin:0 0 6px 0;">🎙️ Studio Perekam Output Audio (RecordRTC)</label>
                        <p>Rekam suara pembacaan teks langsung ke file audio HQ digital untuk didownload.</p>
                    </div>
                    <div style="display:flex; gap:8px; width: 100%;">
                        <button id="btnRecord" class="btn-exp">🔴 Mulai Rekam</button>
                        <button id="btnDownloadRec" class="btn-exp" disabled>💾 Unduh Hasil</button>
                    </div>
                </div>
                <div class="exp-card">
                    <div>
                        <label style="margin:0 0 6px 0;">🧠 Inisialisasi Detektor AI Lokal (ONNX runtime)</label>
                        <p>Cek kesiapan lingkungan neural web lokal untuk pemrosesan model AI masa depan langsung di browser.</p>
                    </div>
                    <button id="btnONNX" class="btn-exp">⚡ Tes ONNX Environment</button>
                </div>
            </div>
        </div>

        <div class="status ready" id="status" style="margin-top:20px;">
            <span class="status-dot"></span><span class="status-text">Sistem Siap</span>
        </div>
    </div>

    <div id="skyScene">
        <div class="bright-sun"></div>
        <div class="fancy-cloud"></div>
        <canvas id="rainbowCanvas"></canvas>
    </div>

    <div id="moneyRainContainer"></div>

    <div class="root_nama">
        <button id="openDonateBtn" class="clas_yusuf">
            ❤️ Donate 
        </button>
    </div>

    <div id="donateModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); justify-content: center; align-items: center;">
        <div style="background-color: white; color: #333; padding: 2rem; border-radius: 1rem; max-width: 450px; width: 90%; text-align: center; position: relative; box-shadow: 0 10px 25px rgba(0,0,0,0.2);">
            <span id="closeDonateBtn" style="position: absolute; right: 1.5rem; top: 1rem; font-size: 1.8rem; cursor: pointer; color: #a1a1aa;">&times;</span>
            <h3 style="margin-top: 0; color: #1e3a8a; font-weight: 700;">Terima Kasih Banyak</h3>
            <p style="font-style: italic; color: #4b5563; font-size: 1rem; line-height: 1.6;">
                "Kehadiran Anda adalah energi bagi kami untuk terus berkarya. Terima kasih telah menggunakan aplikasi ini, dan ketulusan hati Anda melalui donasi ini sangat berarti dalam membantu kami menjaga aplikasi ini tetap hidup dan berkembang."
            </p>
            <hr style="border: 0; border-top: 2px solid #e5e7eb; margin: 2rem 0;">
            <p style="font-weight: bold; margin-bottom: 0.75rem; color: #1f2937; font-size: 1.1rem;">Scan Barcode Paypal untuk Berdonasi</p>
            <div style="background-color: #f3f4f6; padding: 1.5rem; border-radius: 1rem; display: inline-block;">
                <img src="assets/img/qris-paypal.png" alt="QRIS Yusuf Ibrahim Malik Dev" style=" height: 350px; object-fit: contain; display: block; margin: 0 auto;">
            </div>
            <p style="margin-top: 1rem; font-size: 1rem; color: #374151;">Atas Nama: <br><strong style="font-size: 1.25rem; color: #111827;">Yusuf Ibrahim Malik Dev</strong></p>
        </div>
    </div>

     <div id="storm-wrapper" class="yusuf-storm-wrapper">
        <div class="yusuf-cloud-container">
            <div class="yusuf-cloud-layer yusuf-cloud-1"></div>
            <div class="yusuf-cloud-layer yusuf-cloud-2"></div>
        </div>
        
        <div id="rain-container" class="yusuf-rain-container"></div>
        
        <canvas id="lightning-canvas" class="yusuf-lightning-canvas"></canvas>
    </div>

    <footer class="yusuf-footer">
        <div id="ground-cracks" class="yusuf-ground-cracks"></div>
        <div id="ground-flash" class="yusuf-ground-flash"></div>

        <div class="yusuf-footer-container">
            <p class="yusuf-copyright-text">
                &copy; 2026 
                <a href="https://github.com/Yusuf-Ibrahim-Malik-Dev" target="_blank" rel="noopener noreferrer" class="yusuf-storm-trigger">
                    Yusuf Ibrahim Malik Dev
                </a>. 
                All Rights Reserved.
            </p>
        </div>
    </footer>

    <script>
        (function() {
            'use strict';
            if (!window.speechSynthesis) return alert('Browser Anda tidak mendukung Web Speech API!');

            const ALL_LANGUAGES = {
                "af": "Afrikaans", "sq": "Albanian", "am": "Amharic", "ar": "Arabic", "hy": "Armenian", "az": "Azerbaijani", "eu": "Basque", "be": "Belarusian", "bn": "Bengali", "bs": "Bosnian", "bg": "Bulgarian", "ca": "Catalan", "ceb": "Cebuano", "ny": "Chichewa", "zh-CN": "Chinese (Simplified)", "zh-TW": "Chinese (Traditional)", "co": "Corsican", "hr": "Croatian", "cs": "Czech", "da": "Danish", "nl": "Dutch", "en": "English", "eo": "Esperanto", "et": "Estonian", "tl": "Filipino", "fi": "Finnish", "fr": "French", "fy": "Frisian", "gl": "Galician", "ka": "Georgian", "de": "German", "el": "Greek", "gu": "Gujarati", "ht": "Haitian Creole", "ha": "Hausa", "haw": "Hawaiian", "iw": "Hebrew", "hi": "Hindi", "hmn": "Hmong", "hu": "Hungarian", "is": "Icelandic", "ig": "Igbo", "id": "Indonesian", "ga": "Irish", "it": "Italian", "ja": "Japanese", "jw": "Javanese", "kn": "Kannada", "kk": "Kazakh", "km": "Khmer", "rw": "Kinyarwanda", "ko": "Korean", "ku": "Kurdish (Kurmanji)", "ky": "Kyrgyz", "lo": "Lao", "la": "Latin", "lv": "Latvian", "lt": "Lithuanian", "lb": "Luxembourgish", "mk": "Macedonian", "mg": "Malagasy", "ms": "Malay", "ml": "Malayalam", "mt": "Maltese", "mi": "Maori", "mr": "Marathi", "mn": "Mongolian", "my": "Myanmar (Burmese)", "ne": "Nepali", "no": "Norwegian", "or": "Odia (Oriya)", "ps": "Pashto", "fa": "Persian", "pl": "Polish", "pt": "Portuguese", "pa": "Punjabi", "ro": "Romanian", "ru": "Russian", "sm": "Samoan", "gd": "Scots Gaelic", "sr": "Serbian", "st": "Sesotho", "sn": "Shona", "sd": "Sindhi", "si": "Sinhala", "sk": "Slovak", "sl": "Slovenian", "so": "Somali", "es": "Spanish", "su": "Sundanese", "sw": "Swahili", "sv": "Swedish", "tg": "Tajik", "ta": "Tamil", "tt": "Tatar", "te": "Telugu", "th": "Thai", "tr": "Turkish", "tk": "Turkmen", "uk": "Ukrainian", "ur": "Urdu", "ug": "Uyghur", "uz": "Uzbek", "vi": "Vietnamese", "cy": "Welsh", "xh": "Xhosa", "yi": "Yiddish", "yo": "Yoruba", "zu": "Zulu"
            };

            const synth = window.speechSynthesis;
            let voices = [];
            let waveData = [];
            let speechKeepAlive; 
            
            let currentWordPulse = 0; 
            let origTokens = [], transTokens = []; 
            let lastOrigActive = -1, lastTransActive = -1, lastActivePhrase = -1;
            let currentMode = 'original'; 

            let recorderInstance = null;
            let recordedBlob = null;

            const textarea = document.getElementById('text');
            const translateResult = document.getElementById('translateResult');
            const highlightLayer = document.getElementById('highlightLayer');
            const highlightTranslateLayer = document.getElementById('highlightTranslateLayer');
            const parallelWrapper = document.getElementById('parallelWrapper');
            const liveSubtitleText = document.getElementById('liveSubtitleText');
            const liveSubtitleBox = document.getElementById('liveSubtitleBox');
            const floatingControls = document.getElementById('floatingControls');
            const canvas = document.getElementById('waveCanvas');
            const autoFocusSwitch = document.getElementById('autoFocusSwitch');
            let ctx = canvas.getContext('2d');
            
            const translateLangDropdown = document.getElementById('translateLang');
            const voiceLangDropdown = document.getElementById('language');
            const voiceSelect = document.getElementById('voice');
            
            // Effect DOM Elements
            const robotSelect = document.getElementById('robotEffect');
            const transRobotSelect = document.getElementById('transRobotEffect');

            // Layout Checkbox Elements
            const chkDesktop = document.getElementById('chkDesktop');
            const chkAndroid = document.getElementById('chkAndroid');

            if (typeof EasySpeech !== 'undefined') {
                EasySpeech.init({ maxTimeout: 5000 }).catch(e => console.log(e));
            }

            // --- STATE MANAGEMENT: DESKTOP / ANDROID VIEW SWITCHER ---
            chkDesktop.addEventListener('change', function() {
                if(this.checked) {
                    chkAndroid.checked = false;
                    document.body.classList.remove('mode-android');
                } else {
                    this.checked = true; // Minimal salah satu harus tercentang
                }
                setTimeout(resizeCanvas, 150);
            });

            chkAndroid.addEventListener('change', function() {
                if(this.checked) {
                    chkDesktop.checked = false;
                    document.body.classList.add('mode-android');
                } else {
                    this.checked = true; // Minimal salah satu harus tercentang
                }
                setTimeout(resizeCanvas, 150);
            });

            function resizeCanvas() {
                canvas.width = canvas.parentElement.clientWidth;
                canvas.height = canvas.parentElement.clientHeight;
            }
            window.addEventListener('resize', resizeCanvas);
            setTimeout(resizeCanvas, 100);

            function initDropdowns() {
                let optionsHtml = '';
                for (let code in ALL_LANGUAGES) {
                    optionsHtml += `<option value="${code}">${ALL_LANGUAGES[code]} (${code})</option>`;
                }
                translateLangDropdown.innerHTML = optionsHtml;
                translateLangDropdown.value = 'en'; 
            }
            initDropdowns();

            function loadVoices() {
                voices = synth.getVoices();
                if(voices.length) {
                    let availableLangs = [...new Set(voices.map(v => v.lang.split('-')[0]))].sort();
                    let langOptions = '';
                    availableLangs.forEach(lang => {
                        let name = ALL_LANGUAGES[lang] || lang;
                        langOptions += `<option value="${lang}">${name} (${lang})</option>`;
                    });
                    voiceLangDropdown.innerHTML = langOptions;
                    voiceLangDropdown.value = availableLangs.includes('id') ? 'id' : availableLangs[0];
                    updateVoiceList();
                }
            }
            
            function updateVoiceList() {
                let selectedLang = voiceLangDropdown.value;
                let filteredVoices = voices.filter(v => v.lang.startsWith(selectedLang));
                if(filteredVoices.length === 0) filteredVoices = voices;
                voiceSelect.innerHTML = filteredVoices.map((v, i) => `<option value="${voices.indexOf(v)}">${v.name}</option>`).join('');
            }
            
            voiceLangDropdown.addEventListener('change', updateVoiceList);
            if (speechSynthesis.onvoiceschanged !== undefined) speechSynthesis.onvoiceschanged = loadVoices;
            setTimeout(loadVoices, 500);

            // --- TEXT PARSING ---
            function tokenizeText(text, prefix) {
                let tokens = [], html = '', charCount = 0, tokenIdx = 0;
                let lines = text.split('\n');
                
                lines.forEach((line, phraseIdx) => {
                    let regex = /\S+|\s+/g, match;
                    while ((match = regex.exec(line)) !== null) {
                        let str = match[0];
                        if (/\S/.test(str)) { 
                            let id = `${prefix}-word-${tokenIdx}`;
                            tokens.push({ text: str, start: charCount, end: charCount + str.length, id: id, phraseIdx: phraseIdx });
                            html += `<span id="${id}" class="word-mark">${str}</span>`;
                            tokenIdx++;
                        } else {
                            html += str; 
                        }
                        charCount += str.length;
                    }
                    if (phraseIdx < lines.length - 1) {
                        html += '\n';
                        charCount += 1;
                    }
                });
                return { tokens, html };
            }

            function processOriginal() {
                let res = tokenizeText(textarea.value, 'orig');
                origTokens = res.tokens;
                highlightLayer.innerHTML = res.html;
                document.getElementById('charCount').innerText = textarea.value.length;
            }
            textarea.addEventListener('input', () => { processOriginal(); parallelWrapper.innerHTML = ''; });
            processOriginal();

            window.syncScroll = function(srcId, targetId) {
                const srcEl = document.getElementById(srcId);
                const targetEl = document.getElementById(targetId);
                if(srcEl && targetEl) {
                    targetEl.scrollTop = srcEl.scrollTop;
                }
            }

            // --- TRANSLATE ---
            document.getElementById('translateBtn').onclick = async () => {
                let text = textarea.value.trim();
                if(!text) return;
                document.getElementById('translateStatus').innerText = '⏳ Sedang Menerjemahkan Super Akurat...';
                
                try {
                    let lines = textarea.value.split('\n');
                    let translatedLines = [];
                    let target = translateLangDropdown.value;

                    for(let line of lines) {
                        if(!line.trim()) {
                            translatedLines.push('');
                            continue;
                        }
                        let res = await fetch(`https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=${target}&dt=t&q=${encodeURIComponent(line)}`);
                        let data = await res.json();
                        let lineTrans = '';
                        data[0].forEach(arr => { if(arr[0]) lineTrans += arr[arr.length - 1] === '\n' ? arr[0].trim() : arr[0]; });
                        translatedLines.push(lineTrans.trim());
                    }

                    let finalTrans = translatedLines.join('\n');
                    translateResult.value = finalTrans;
                    
                    let res = tokenizeText(finalTrans, 'trans');
                    transTokens = res.tokens;
                    highlightTranslateLayer.innerHTML = res.html;
                    
                    document.getElementById('translateStatus').innerText = '✅ Terjemahan Selesai & Data Tersinkronisasi';
                    document.getElementById('playTranslate').disabled = false;
                    
                    buildParallelDOM();
                } catch(e) {
                    console.error(e);
                    document.getElementById('translateStatus').innerText = '❌ Gagal Terjemah: Cek Koneksi Internet / API Limit';
                }
            };

            document.getElementById('clearTranslateBtn').onclick = () => {
                translateResult.value = ''; transTokens = [];
                highlightTranslateLayer.innerHTML = ''; parallelWrapper.innerHTML = '';
                document.getElementById('playTranslate').disabled = true;
                document.getElementById('translateStatus').innerText = '💡 Papan dibersihkan.';
            };

            // --- BUILD PARALLEL DOM ---
            function buildParallelDOM() {
                let maxPhrase = Math.max(
                    origTokens.length ? origTokens[origTokens.length-1].phraseIdx : 0, 
                    transTokens.length ? transTokens[transTokens.length-1].phraseIdx : 0
                );
                
                let html = '';
                let hasData = false;

                for(let p = 0; p <= maxPhrase; p++) {
                    let oWords = origTokens.filter(t => t.phraseIdx === p);
                    let tWords = transTokens.filter(t => t.phraseIdx === p);
                    
                    if(oWords.length === 0 && tWords.length === 0) continue;
                    hasData = true;

                    let oHtml = oWords.map(w => {
                        let globalIdx = origTokens.indexOf(w);
                        return `<span id="par-orig-word-${globalIdx}">${w.text}</span>`;
                    }).join(' ');

                    let tHtml = tWords.map(w => {
                        let globalIdx = transTokens.indexOf(w);
                        return `<span id="par-trans-word-${globalIdx}">${w.text}</span>`;
                    }).join(' ');
                    
                    html += `
                    <div class="phrase-pair" id="phrase-box-${p}">
                        <div class="parallel-text orig-text">${oHtml}</div>
                        <div class="parallel-text trans-text">${tHtml}</div>
                    </div>`;
                }

                if (hasData) {
                    parallelWrapper.innerHTML = html;
                } else {
                    parallelWrapper.innerHTML = `<span style="color:rgba(255,255,255,0.25); font-style: italic; font-size: 13px;">Data frasa per-kata akan terbentuk otomatis setelah Anda menerjemahkan...</span>`;
                }
            }

            function findTokenIndex(charIndex, tokens) {
                for(let i=0; i<tokens.length; i++) {
                    if(charIndex >= tokens[i].start && charIndex < tokens[i].end) return i;
                }
                for(let i=0; i<tokens.length; i++) {
                    if(charIndex < tokens[i].start) return i; 
                }
                return tokens.length - 1;
            }

            function updateSyncUI(charIndex, isTrans) {
                let tokens = isTrans ? transTokens : origTokens;
                if(!tokens.length) return;
                
                let activeIdx = findTokenIndex(charIndex, tokens);
                if(activeIdx === -1) return;

                let token = tokens[activeIdx];
                currentWordPulse = 1.0; 

                document.querySelectorAll('.active').forEach(el => el.classList.remove('active'));

                if(isTrans) {
                    let transEl = document.getElementById(`trans-word-${activeIdx}`);
                    if(transEl) transEl.classList.add('active');
                    
                    let parTransEl = document.getElementById(`par-trans-word-${activeIdx}`);
                    if(parTransEl) parTransEl.classList.add('active');

                    let currentPhraseOrigWords = origTokens.filter(tok => tok.phraseIdx === token.phraseIdx);
                    let currentPhraseTransWords = transTokens.filter(tok => tok.phraseIdx === token.phraseIdx);
                    
                    if(currentPhraseOrigWords.length > 0 && currentPhraseTransWords.length > 0) {
                        let relativeTransIdx = currentPhraseTransWords.indexOf(token);
                        let ratio = currentPhraseOrigWords.length / currentPhraseTransWords.length;
                        let targetOrigCenter = Math.floor(relativeTransIdx * ratio);
                        let groupSize = Math.max(2, Math.round(ratio)); 
                        
                        let startGroupIdx = Math.max(0, targetOrigCenter - Math.floor((groupSize - 1) / 2));
                        let endGroupIdx = Math.min(currentPhraseOrigWords.length - 1, startGroupIdx + groupSize - 1);
                        
                        for(let i = startGroupIdx; i <= endGroupIdx; i++) {
                            let targetTok = currentPhraseOrigWords[i];
                            let globalOrigIdx = origTokens.indexOf(targetTok);
                            
                            let origEl = document.getElementById(`orig-word-${globalOrigIdx}`);
                            if(origEl) origEl.classList.add('active');
                            
                            let parOrigEl = document.getElementById(`par-orig-word-${globalOrigIdx}`);
                            if(parOrigEl) parOrigEl.classList.add('active');
                        }
                    }
                } else {
                    let origEl = document.getElementById(`orig-word-${activeIdx}`);
                    if(origEl) origEl.classList.add('active');
                    
                    let parOrigEl = document.getElementById(`par-orig-word-${activeIdx}`);
                    if(parOrigEl) parOrigEl.classList.add('active');
                }

                let pBox = document.getElementById('phrase-box-' + token.phraseIdx);
                if(pBox && autoFocusSwitch.checked) {
                    pBox.scrollIntoView({behavior: "smooth", block: "center"});
                }

                liveSubtitleText.innerText = token.text;

                if(lastActivePhrase !== token.phraseIdx) {
                    if(lastActivePhrase !== -1) {
                        let oldPBox = document.getElementById(`phrase-box-${lastActivePhrase}`);
                        if(oldPBox) oldPBox.classList.remove('active-phrase', 'active-phrase-trans');
                    }
                    let newPBox = document.getElementById(`phrase-box-${token.phraseIdx}`);
                    if(newPBox) newPBox.classList.add(isTrans ? 'active-phrase-trans' : 'active-phrase');
                    lastActivePhrase = token.phraseIdx;
                }

                if(isTrans) lastTransActive = activeIdx;
                else lastOrigActive = activeIdx;
            }

            function clearAllHighlights() {
                document.querySelectorAll('.active').forEach(el => el.classList.remove('active'));
                document.querySelectorAll('.active-phrase, .active-phrase-trans').forEach(el => el.classList.remove('active-phrase', 'active-phrase-trans'));
                lastOrigActive = -1; lastTransActive = -1; lastActivePhrase = -1;
            }

            function initWaveData() {
                waveData = [];
                for(let i=0; i<60; i++) waveData.push({ amp: 0.3 + Math.random()*0.5, phase: Math.random()*Math.PI*2, speed: 0.05 + Math.random()*0.05 });
            }
            function drawWave(time, isSpeaking, isTrans) {
                if (!canvas.width || !canvas.height) return;
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.fillStyle = 'rgba(124, 58, 237, 0.02)';
                ctx.fillRect(0, 0, canvas.width, canvas.height);

                let barWidth = canvas.width / waveData.length;
                if(isSpeaking) currentWordPulse = Math.max(0, currentWordPulse - 0.08);

                for (let i = 0; i < waveData.length; i++) {
                    let d = waveData[i];
                    let baseAmp = isSpeaking ? 15 : 4;
                    let jumpAmp = isSpeaking ? (currentWordPulse * Math.abs(Math.sin(i)) * 60) : 0;
                    let h = baseAmp + jumpAmp + (Math.sin(time * d.speed + d.phase) * d.amp * (isSpeaking?15:5));
                    
                    h = Math.min(canvas.height - 10, h); 
                    let y = (canvas.height / 2) - (h / 2);

                    let color = 'hsla(260, 40%, 40%, 0.3)';
                    if(isSpeaking) color = isTrans ? `hsla(217, 90%, 65%, 0.8)` : `hsla(0, 80%, 65%, 0.8)`;
                    
                    ctx.fillStyle = color;
                    ctx.fillRect(i * barWidth + 2, y, barWidth - 4, h);
                }
            }
            let time = 0;
            function animateWave() {
                time += 0.2;
                let active = (synth.speaking && !synth.paused) || (typeof responsiveVoice !== 'undefined' && responsiveVoice.isPlaying());
                let isTrans = document.getElementById('playTranslate').disabled === false && lastTransActive !== -1;
                drawWave(time, active, isTrans);
                requestAnimationFrame(animateWave);
            }
            initWaveData(); animateWave();

            function startKeepAlive() {
                if(speechKeepAlive) clearInterval(speechKeepAlive);
                speechKeepAlive = setInterval(() => {
                    if(synth.speaking && !synth.paused) { synth.pause(); synth.resume(); }
                }, 10000); 
            }

            // --- TTS SPEAK ENGINE ---
            function speak(text, isTrans = false) {
                if(synth.speaking) synth.cancel();
                if(typeof responsiveVoice !== 'undefined' && responsiveVoice.isPlaying()) responsiveVoice.cancel();
                if(!text.trim()) return;
                clearAllHighlights();

                currentMode = isTrans ? 'translation' : 'original';
                let utter = new SpeechSynthesisUtterance(text);
                
                let selVoice = voices[document.getElementById('voice').value];
                if(isTrans) {
                    let targetLang = translateLangDropdown.value;
                    let matchingVoice = voices.find(v => v.lang.startsWith(targetLang));
                    if(matchingVoice) selVoice = matchingVoice;
                    else utter.lang = targetLang; 
                }
                if(selVoice) utter.voice = selVoice;

                let botMode = isTrans ? transRobotSelect.value : robotSelect.value;
                
                if(botMode !== 'none') {
                    if(botMode === 'cyborg') { utter.pitch = 0.5; utter.rate = 1.0; }
                    else if(botMode === 'robot_deep') { utter.pitch = 0.1; utter.rate = 0.6; }
                    else if(botMode === 'alien') { utter.pitch = 2.0; utter.rate = 1.1; }
                    else if(botMode === 'chipmunk') { utter.pitch = 2.0; utter.rate = 1.7; }
                    else if(botMode === 'slow') { utter.pitch = 0.8; utter.rate = 0.2; } 
                    else if(botMode === 'fast') { utter.pitch = 1.1; utter.rate = 3.0; } 
                } else {
                    utter.rate = parseFloat(document.getElementById(isTrans ? 'transRate' : 'rate').value);
                    utter.pitch = parseFloat(document.getElementById(isTrans ? 'transPitch' : 'pitch').value);
                }
                
                utter.volume = parseFloat(document.getElementById(isTrans ? 'transVolume' : 'volume').value);

                utter.onstart = () => {
                    startKeepAlive();
                    liveSubtitleBox.classList.add(isTrans ? 'active-trans' : 'active-orig');
                    floatingControls.classList.add('show'); 
                    
                    document.getElementById('status').className = 'status ' + (isTrans ? 'speaking-trans' : 'speaking');
                    document.getElementById('status').innerHTML = '<span class="status-dot"></span><span class="status-text">Sedang Membaca...</span>';
                    if(!isTrans) document.getElementById('play').classList.add('speaking');
                };

                utter.onboundary = (e) => {
                    if(e.name === 'word') updateSyncUI(e.charIndex, isTrans);
                };

                utter.onend = () => cleanup();
                utter.onerror = () => cleanup();

                synth.speak(utter);
            }

            function cleanup() {
                if(speechKeepAlive) clearInterval(speechKeepAlive);
                liveSubtitleBox.classList.remove('active-orig', 'active-trans');
                floatingControls.classList.remove('show'); 
                liveSubtitleText.innerText = '...';
                document.getElementById('status').className = 'status ready';
                document.getElementById('status').innerHTML = '<span class="status-dot"></span><span class="status-text">Sistem Siap</span>';
                document.getElementById('play').classList.remove('speaking');
                clearAllHighlights();
            }

            function triggerPause() {
                if (typeof responsiveVoice !== 'undefined' && responsiveVoice.isPlaying()) {
                    responsiveVoice.pause();
                } else {
                    synth.pause(); 
                }
                document.getElementById('status').innerHTML = '<span class="status-dot" style="background:#f59e0b"></span><span class="status-text">Paused (Spasi untuk Resume)</span>';
            }

            // Event Listeners Kontrol Utama
            document.getElementById('play').onclick = () => speak(textarea.value, false);
            document.getElementById('playTranslate').onclick = () => speak(translateResult.value, true);
            
            document.getElementById('pause').onclick = () => { if(synth.paused) { synth.resume(); document.getElementById('status').innerHTML = '<span class="status-dot"></span><span>Resumed</span>'; } else { triggerPause(); } };
            document.getElementById('resume').onclick = () => { synth.resume(); document.getElementById('status').innerHTML = '<span class="status-dot"></span><span>Resumed</span>'; };
            document.getElementById('stop').onclick = () => { synth.cancel(); cleanup(); };
            document.getElementById('stopTranslate').onclick = () => { synth.cancel(); cleanup(); };

            document.getElementById('floatPause').onclick = () => { if(synth.paused) { synth.resume(); } else { triggerPause(); } };
            document.getElementById('floatResume').onclick = () => synth.resume();
            document.getElementById('floatStop').onclick = () => { synth.cancel(); cleanup(); };

            window.addEventListener('keydown', function(e) {
                if (e.code === 'Space' || e.keyCode === 32) {
                    if (document.activeElement === textarea) return;
                    if (synth.speaking) {
                        e.preventDefault(); 
                        if(synth.paused) synth.resume(); else triggerPause();
                    }
                }
            });

            // --- EXTRA LIBRARIES HANDLERS ---
            document.getElementById('btnResponsive').onclick = () => {
                let text = textarea.value.trim();
                if(!text || typeof responsiveVoice === 'undefined') return;
                synth.cancel(); cleanup();
                let rvLang = voiceLangDropdown.value === 'id' ? "Indonesian Female" : "UK English Female";
                responsiveVoice.speak(text, rvLang, {
                    rate: parseFloat(document.getElementById('rate').value),
                    pitch: parseFloat(document.getElementById('pitch').value),
                    volume: parseFloat(document.getElementById('volume').value),
                    onstart: () => {
                        liveSubtitleBox.classList.add('active-orig');
                        document.getElementById('status').className = 'status speaking';
                        liveSubtitleText.innerText = "🔊 Cloud Voice Active...";
                    },
                    onend: () => cleanup()
                });
            };

            let isListening = false;
            document.getElementById('btnListen').onclick = () => {
                if(typeof annyang === 'undefined') return;
                if(!isListening) {
                    annyang.setLanguage(voiceLangDropdown.value === 'id' ? 'id-ID' : 'en-US');
                    annyang.removeCommands();
                    annyang.addCallback('result', function(phrases) {
                        if(phrases && phrases[0]) {
                            textarea.value += (textarea.value ? " " : "") + phrases[0];
                            processOriginal();
                        }
                    });
                    annyang.start({ autoRestart: true, continuous: true });
                    isListening = true;
                    document.getElementById('btnListen').innerText = "🛑 Hentikan Mendengar";
                    document.getElementById('btnListen').style.background = "linear-gradient(135deg, #ef4444, #dc2626)";
                } else {
                    annyang.abort();
                    isListening = false;
                    document.getElementById('btnListen').innerText = "🎙️ Mulai Dikte Suara";
                    document.getElementById('btnListen').style.background = "linear-gradient(135deg, #06b6d4, #0891b2)";
                }
            };

            let isRecording = false;
            document.getElementById('btnRecord').onclick = async () => {
                if (typeof RecordRTC === 'undefined') return alert('Library RecordRTC belum termuat sempurna!');
                if (!isRecording) {
                    try {
                        let stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                        recorderInstance = new RecordRTC(stream, { type: 'audio', mimeType: 'audio/wav', recorderType: StereoAudioRecorder });
                        recorderInstance.startRecording();
                        isRecording = true;
                        document.getElementById('btnRecord').innerText = "⏹ Hentikan Rekam";
                        document.getElementById('btnRecord').style.background = "linear-gradient(135deg, #ef4444, #b91c1c)";
                    } catch (err) { alert(err.message); }
                } else {
                    if (recorderInstance) {
                        recorderInstance.stopRecording(function() {
                            recordedBlob = recorderInstance.getBlob();
                            document.getElementById('btnDownloadRec').disabled = false;
                            isRecording = false;
                            document.getElementById('btnRecord').innerText = "🎙️ Mulai Rekam";
                            document.getElementById('btnRecord').style.background = "linear-gradient(135deg, #10b981, #047857)";
                        });
                    }
                }
            };

            document.getElementById('btnDownloadRec').onclick = () => {
                if (!recordedBlob) return;
                let fileURL = URL.createObjectURL(recordedBlob);
                let downloadLink = document.createElement('a');
                downloadLink.href = fileURL;
                downloadLink.download = 'WaveSpeech_Studio_Output.wav';
                downloadLink.click();
            };

            document.getElementById('btnONNX').onclick = async () => {
                if (typeof ort === 'undefined') return alert('Library ONNX Runtime Web belum termuat!');
                if (ort.env) alert('✅ ONNX Runtime Sukses! Environment terdeteksi.');
            };

        })();
    </script>
       <script>
        document.addEventListener("DOMContentLoaded", () => {
    
    // =======================================
    // ROOT_JAVA_NAMA FUNCTION_YUSUF SYSTEM
    // =======================================
    const root_java_nama = {
        isStorming: false,
        lightningTimer: null,
        
        // Fungsi utama inisialisasi cuaca Yusuf
        function_yusuf: function() {
            const trigger = document.querySelector(".yusuf-storm-trigger");
            const stormWrapper = document.getElementById("storm-wrapper");
            const rainContainer = document.getElementById("rain-container");
            const canvas = document.getElementById("lightning-canvas");
            const ctx = canvas.getContext("2d");
            const groundCracks = document.getElementById("ground-cracks");
            const groundFlash = document.getElementById("ground-flash");

            // Mengatur ukuran canvas layar penuh
            function resizeCanvas() {
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;
            }
            window.addEventListener("resize", resizeCanvas);
            resizeCanvas();

            // 1. Sub-fungsi Membuat Hujan
            function generateRain() {
                rainContainer.innerHTML = "";
                const maxDrops = 150;
                for (let i = 0; i < maxDrops; i++) {
                    const drop = document.createElement("div");
                    drop.classList.add("yusuf-drop");
                    drop.style.left = `${Math.random() * 100}%`;
                    drop.style.top = `${Math.random() * -50}px`;
                    drop.style.animationDuration = `${0.4 + Math.random() * 0.4}s`;
                    drop.style.animationDelay = `${Math.random() * 1.5}s`;
                    rainContainer.appendChild(drop);
                }
            }

            // 2. Sub-fungsi Menggambar Petir Lengkang-Lengkung (Fractal)
            function drawLightningFractal(startX, startY, endX, endY, displace, props) {
                if (displace < props.minDisplace) {
                    ctx.beginPath();
                    ctx.moveTo(startX, startY);
                    ctx.lineTo(endX, endY);
                    ctx.strokeStyle = props.color;
                    ctx.lineWidth = props.width;
                    ctx.shadowBlur = 15;
                    ctx.shadowColor = "#00fff2";
                    ctx.stroke();
                    return;
                }

                const midX = (startX + endX) / 2 + (Math.random() - 0.5) * displace;
                const midY = (startY + endY) / 2 + (Math.random() - 0.5) * displace;

                drawLightningFractal(startX, startY, midX, midY, displace / 2, props);
                drawLightningFractal(midX, midY, endX, endY, displace / 2, props);

                // Membuat sub-cabang kecil liar di udara
                if (Math.random() < 0.12 && displace > 10) { 
                    const branchEndX = midX + (Math.random() - 0.5) * 80;
                    const branchEndY = midY + Math.random() * 60;
                    drawLightningFractal(midX, midY, branchEndX, branchEndY, displace / 2, {
                        ...props,
                        width: props.width * 0.5
                    });
                }
            }

            // 3. Sub-fungsi Pemicu Ledakan Sambaran Petir
            const triggerLightningStrike = () => {
                if (!root_java_nama.isStorming) return;

                ctx.clearRect(0, 0, canvas.width, canvas.height);

                const triggerRect = trigger.getBoundingClientRect();
                const startX = Math.random() * canvas.width;
                const startY = 40; 
                const endX = triggerRect.left + (Math.random() * triggerRect.width);
                const endY = canvas.height - 90; 

                const properties = {
                    color: "rgba(235, 255, 255, 1)",
                    width: 3.5,
                    minDisplace: 4
                };

                // Gambar kilatan petir
                drawLightningFractal(startX, startY, endX, endY, 160, properties);

                // Aktifkan visual efek sekunder (Guncangan & Retakan Tanah)
                stormWrapper.classList.add("ambient-flash");
                groundCracks.classList.add("cracks-active");
                groundFlash.classList.add("flash-active");
                document.body.classList.add("shake-body");

                // Bersihkan efek instan berkedip
                setTimeout(() => {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    stormWrapper.classList.remove("ambient-flash");
                    document.body.classList.remove("shake-body");
                }, 180);

                setTimeout(() => {
                    groundCracks.classList.remove("cracks-active");
                    groundFlash.classList.remove("flash-active");
                }, 400);

                // Set giliran petir acak berikutnya jika kursor masih diam disana
                const nextStrike = 1000 + Math.random() * 2000;
                root_java_nama.lightningTimer = setTimeout(triggerLightningStrike, nextStrike);
            };

            // =======================================
            // EVENT LISTENERS (HOVER CONTROL)
            // =======================================
            
            // Ketika kursor diam/masuk ke area teks
            trigger.addEventListener("mouseenter", () => {
                root_java_nama.isStorming = true;
                
                // Aktifkan tema badai secara penuh
                document.body.classList.add("yusuf-storm-active");
                stormWrapper.classList.add("active");
                trigger.style.textShadow = "0 0 12px #00fff2, 0 0 25px #00fff2";
                
                generateRain();
                
                // Petir menyambar perdana setelah kursor diam 600ms
                root_java_nama.lightningTimer = setTimeout(triggerLightningStrike, 600);
            });

            // Ketika kursor keluar (Cuaca kembali cerah)
            trigger.addEventListener("mouseleave", () => {
                root_java_nama.isStorming = false;
                
                // Kembalikan ke tema cerah semula
                document.body.classList.remove("yusuf-storm-active");
                stormWrapper.classList.remove("active");
                trigger.style.textShadow = "none";
                
                clearTimeout(root_java_nama.lightningTimer);
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                
                // Bersihkan tetesan hujan dari DOM
                setTimeout(() => {
                    if (!root_java_nama.isStorming) rainContainer.innerHTML = "";
                }, 600);
            });
        }
    };

    // Jalankan sistem cuaca Yusuf
    root_java_nama.function_yusuf();
});
    </script>
    
<script>
    const modal = document.getElementById("donateModal");
    const openBtn = document.getElementById("openDonateBtn");
    const closeBtn = document.getElementById("closeDonateBtn");
    
    const moneyRainContainer = document.getElementById("moneyRainContainer");
    const skyScene = document.getElementById("skyScene");
    const canvas = document.getElementById("rainbowCanvas");
    const ctx = canvas.getContext("2d");
    
    let rainInterval;
    let animationFrameId;
    
    // Variabel Kendali Animasi
    let t = 0; 
    let stickmanDirection = 1; // 1 = Meluncur Turun, -1 = Memanjat Naik, 0 = Diam Sejenak
    let blinkAlpha = 0.65; 
    let blinkDirection = 0.008; // Transisi kedap-kedip diperhalus pelan

    function getBezierPoint(t, p0, p1, p2) {
        const x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
        const y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
        return { x, y };
    }

    // Menggambar 4 Warna Pelangi Utama Pilihanmu (Merah, Kuning, Hijau, Biru)
    function drawRainbow(p0, p1, p2) {
        const customColors = [
            "rgba(255, 50, 50, ",   // Merah
            "rgba(255, 235, 50, ",  // Kuning
            "rgba(50, 215, 50, ",   // Hijau
            "rgba(50, 130, 255, "   // Biru
        ];

        ctx.save();
        // Beri efek blur alami agar antar warna membaur natural
        ctx.shadowBlur = 10;
        ctx.shadowColor = "rgba(255,255,255,0.4)";
        
        customColors.forEach((color, index) => {
            ctx.beginPath();
            ctx.moveTo(p0.x, p0.y);
            ctx.quadraticCurveTo(p1.x, p1.y, p2.x, p2.y);
            ctx.strokeStyle = color + blinkAlpha + ")";
            ctx.lineWidth = 36 - (index * 5); // Ketebalan layer yang proporsional
            ctx.lineCap = "round";
            ctx.stroke();
        });
        ctx.restore();
    }

    // Desain Anatomi Stickman Alami & Proporsional
    function drawStickman(pos, t, dir) {
        ctx.save();
        ctx.translate(pos.x, pos.y - 18); 
        ctx.strokeStyle = "#FFF"; // Warna abu gelap natural
        ctx.lineWidth = 3;
        ctx.lineCap = "round";

        let frame = Math.floor(Date.now() / 150) % 4; // Ritme gerakan kaki/tangan lebih lambat

        // KEPALA
        ctx.beginPath();
        ctx.arc(0, -18, 5, 0, Math.PI * 2);
        ctx.fillStyle = "#FFF";
        ctx.fill();
        ctx.stroke();

        // BADAN
        ctx.beginPath();
        ctx.moveTo(0, -13);
        ctx.lineTo(0, 0);
        ctx.stroke();

        if (dir === 1) { // --- PERJALANAN TURUN ---
            if (t > 0.15 && t < 0.85) { 
                // Pose Meluncur (Sliding) Alami
                ctx.rotate(-0.25); // Condong rileks ke belakang
                // Posisi Kaki selonjoran santai mengikuti arus luncuran
                ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(10, 4); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(7, 9); ctx.stroke();
                // Tangan diangkat ke atas menikmati seluncuran pelangi
                ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(-8, -18); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(8, -16); ctx.stroke();
            } else { 
                // Pose Jalan Kaki Normal waktu keluar dari awan / mendarat
                let legCycle = frame % 2 === 0 ? 8 : 3;
                ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(-5, 10); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(5, legCycle); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(-4, -2); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(4, -4); ctx.stroke();
            }
        } else { // --- PROSES MEMANJAT NAIK (Dibuat Lambat & Natural) ---
            ctx.rotate(0.18); // Sedikit merunduk maju ke depan menahan beban tanjakan
            let climbCycle = frame % 2 === 0;
            // Langkah kaki memanjat secara bergiliran
            ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(-6, climbCycle ? 10 : 5); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(4, climbCycle ? 4 : 10); ctx.stroke();
            // Tangan menggapai ke depan menarik tubuh naik ke atas pelangi
            ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(-10, -6); ctx.stroke(); 
            ctx.beginPath(); ctx.moveTo(0, -10); ctx.lineTo(5, -1); ctx.stroke();
        }

        ctx.restore();
    }

    // Loop Animasi
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        if(canvas.width !== window.innerWidth || canvas.height !== window.innerHeight) {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }

        const btnRect = openBtn.getBoundingClientRect();
        
        const p0 = { x: 110, y: 75 }; 
        const p2 = { x: btnRect.left + (btnRect.width / 2), y: btnRect.top }; 
        const p1 = { x: (p0.x + p2.x) / 1.9, y: -130 }; 

        // Efek Kedap Kedip Natural
        blinkAlpha += blinkDirection;
        if (blinkAlpha >= 0.8 || blinkAlpha <= 0.45) blinkDirection = -blinkDirection;

        drawRainbow(p0, p1, p2);

        // Pengaturan Kecepatan Durasi (Dibuat jauh lebih pelan agar natural)
        if (stickmanDirection === 1) {
            t += 0.0025; // Kecepatan meluncur turun diperlambat setengahnya
            if (t >= 1) {
                t = 1;
                stickmanDirection = 0; 
                setTimeout(() => { stickmanDirection = -1; }, 1200); // Istirahat sejenak di atas tombol
            }
        } else if (stickmanDirection === -1) {
            t -= 0.0018; // Kecepatan memanjat naik dibuat sangat tenang dan realistis
            if (t <= 0) {
                t = 0;
                stickmanDirection = 0;
                setTimeout(() => { stickmanDirection = 1; }, 600); // Jeda sebelum keluar awan kembali
            }
        }

        const currentPos = getBezierPoint(t, p0, p1, p2);
        
        if (stickmanDirection !== 0 || t > 0) {
            drawStickman(currentPos, t, stickmanDirection === 0 ? -1 : stickmanDirection);
        }

        animationFrameId = requestAnimationFrame(animate);
    }

    function createMoney() {
        const paperMoney = ['💵', '💸']; const coins = ['🪙'];
        const isCoin = Math.random() > 0.5;
        const item = document.createElement("div");
        item.classList.add("money-item");
        
        if (isCoin) {
            item.innerText = coins[Math.floor(Math.random() * coins.length)];
            item.classList.add("coin-animation");
            item.style.fontSize = (Math.random() * 12 + 16) + 'px';
        } else {
            item.innerText = paperMoney[Math.floor(Math.random() * paperMoney.length)];
            item.classList.add("bill-animation");
            item.style.fontSize = (Math.random() * 16 + 22) + 'px';
        }
        item.style.left = Math.random() * 100 + 'vw';
        item.style.animationDuration = (Math.random() * 1.5 + 2.5) + 's';
        
        moneyRainContainer.appendChild(item);
        setTimeout(() => { item.remove(); }, 4000);
    }

    // HOVER
    openBtn.addEventListener("mouseenter", () => {
        skyScene.style.display = "block";
        moneyRainContainer.style.display = "block";
        t = 0; stickmanDirection = 1; 
        animate(); 
        rainInterval = setInterval(createMoney, 50); 
    });

    openBtn.addEventListener("mouseleave", () => {
        cancelAnimationFrame(animationFrameId);
        clearInterval(rainInterval);
        skyScene.style.display = "none";
        moneyRainContainer.style.display = "none";
        moneyRainContainer.innerHTML = ''; 
    });

    openBtn.onclick = function() {
        modal.style.display = "flex";
        cancelAnimationFrame(animationFrameId);
        clearInterval(rainInterval);
        skyScene.style.display = "none";
        moneyRainContainer.style.display = "none";
    }
    closeBtn.onclick = function() { modal.style.display = "none"; }
    window.onclick = function(event) { if (event.target == modal) { modal.style.display = "none"; } }
</script>
</body>
</html>