  
        (function() {
            'use strict';

            if (!window.speechSynthesis) {
                document.getElementById('status').innerHTML = '❌ Browser Anda tidak mendukung Text-to-Speech';
                document.getElementById('status').className = 'status error';
                return;
            }

            const synth = window.speechSynthesis;
            let voices = [];
            let isSpeaking = false;
            let isPaused = false;
            let currentUtterance = null;
            let animationId = null;
            let waveData = [];
            let textCharIndex = 0;
            let voicesLoaded = false;
            let loadAttempts = 0;
            const maxLoadAttempts = 30;

            // Translate state
            let translateUtterance = null;
            let isTranslateSpeaking = false;

            // Phonetic state
            let currentWords = [];
            let currentWordIndex = -1;
            let currentLetterIndex = -1;
            let phoneticDisplayMode = 'original'; // 'original' or 'translated'

            // Parallel phrase state
            let parallelPairs = [];
            let parallelActiveIndex = -1;

            // DOM Elements
            const voiceSelect = document.getElementById("voice");
            const languageSelect = document.getElementById("language");
            const statusEl = document.getElementById("status");
            const statusText = statusEl.querySelector('.status-text');
            const voiceStatus = document.getElementById('voiceStatus');
            const textarea = document.getElementById('text');
            const highlightLayer = document.getElementById('highlightLayer');
            const charCount = document.getElementById('charCount');
            const wordCount = document.getElementById('wordCount');
            const canvas = document.getElementById('waveCanvas');
            const ctx = canvas.getContext('2d');
            const playBtn = document.getElementById('play');
            const pauseBtn = document.getElementById('pause');
            const resumeBtn = document.getElementById('resume');
            const stopBtn = document.getElementById('stop');

            // Translate elements
            const translateLang = document.getElementById('translateLang');
            const translateResult = document.getElementById('translateResult');
            const translateStatus = document.getElementById('translateStatus');
            const translateCharCount = document.getElementById('translateCharCount');
            const translateBtn = document.getElementById('translateBtn');
            const clearTranslateBtn = document.getElementById('clearTranslateBtn');
            const playTranslateBtn = document.getElementById('playTranslate');
            const stopTranslateBtn = document.getElementById('stopTranslate');

            // Phonetic elements
            const phoneticWrapper = document.getElementById('phoneticWrapper');
            const phoneticWordCount = document.getElementById('phoneticWordCount');
            const phoneticLanguageSelect = document.getElementById('phoneticLanguageSelect');

            // Parallel elements
            const parallelWrapper = document.getElementById('parallelWrapper');
            const parallelPairCount = document.getElementById('parallelPairCount');

            // Phonetic language select change
            phoneticLanguageSelect.addEventListener('change', function() {
                phoneticDisplayMode = this.value;
                // Refresh phonetic display with current state
                const text = textarea.value;
                if (phoneticDisplayMode === 'translated' && translateResult.value.trim()) {
                    updatePhonetic(translateResult.value);
                } else {
                    updatePhonetic(text);
                }
                // Also update word count
                const words = phoneticDisplayMode === 'translated' && translateResult.value.trim() ?
                    translateResult.value.trim().split(/\s+/) :
                    text.trim().split(/\s+/);
                phoneticWordCount.textContent = words.length + ' kata';
            });

            const languageNames = {
                'af': 'Afrikaans',
                'ar': 'العربية (Arabic)',
                'bg': 'Български (Bulgarian)',
                'bn': 'বাংলা (Bengali)',
                'ca': 'Català (Catalan)',
                'cs': 'Čeština (Czech)',
                'cy': 'Cymraeg (Welsh)',
                'da': 'Dansk (Danish)',
                'de': 'Deutsch (German)',
                'el': 'Ελληνικά (Greek)',
                'en': 'English',
                'en-AU': 'English (Australia)',
                'en-GB': 'English (UK)',
                'en-US': 'English (US)',
                'eo': 'Esperanto',
                'es': 'Español (Spanish)',
                'es-ES': 'Español (Spain)',
                'es-MX': 'Español (Mexico)',
                'et': 'Eesti (Estonian)',
                'fa': 'فارسی (Persian)',
                'fi': 'Suomi (Finnish)',
                'fil': 'Filipino',
                'fr': 'Français (French)',
                'fr-CA': 'Français (Canada)',
                'ga': 'Gaeilge (Irish)',
                'gl': 'Galego (Galician)',
                'gu': 'ગુજરાતી (Gujarati)',
                'he': 'עברית (Hebrew)',
                'hi': 'हिन्दी (Hindi)',
                'hr': 'Hrvatski (Croatian)',
                'hu': 'Magyar (Hungarian)',
                'hy': 'Հայերեն (Armenian)',
                'id': 'Bahasa Indonesia',
                'is': 'Íslenska (Icelandic)',
                'it': 'Italiano (Italian)',
                'ja': '日本語 (Japanese)',
                'jv': 'Basa Jawa (Javanese)',
                'ka': 'ქართული (Georgian)',
                'kk': 'Қазақша (Kazakh)',
                'km': 'ភាសាខ្មែរ (Khmer)',
                'kn': 'ಕನ್ನಡ (Kannada)',
                'ko': '한국어 (Korean)',
                'lo': 'ລາວ (Lao)',
                'lt': 'Lietuvių (Lithuanian)',
                'lv': 'Latviešu (Latvian)',
                'mk': 'Македонски (Macedonian)',
                'ml': 'മലയാളം (Malayalam)',
                'mn': 'Монгол (Mongolian)',
                'mr': 'मराठी (Marathi)',
                'ms': 'Bahasa Melayu (Malay)',
                'my': 'မြန်မာစာ (Burmese)',
                'ne': 'नेपाली (Nepali)',
                'nl': 'Nederlands (Dutch)',
                'no': 'Norsk (Norwegian)',
                'pa': 'ਪੰਜਾਬੀ (Punjabi)',
                'pl': 'Polski (Polish)',
                'pt': 'Português (Portuguese)',
                'pt-BR': 'Português (Brazil)',
                'pt-PT': 'Português (Portugal)',
                'ro': 'Română (Romanian)',
                'ru': 'Русский (Russian)',
                'si': 'සිංහල (Sinhala)',
                'sk': 'Slovenčina (Slovak)',
                'sl': 'Slovenščina (Slovenian)',
                'sq': 'Shqip (Albanian)',
                'sr': 'Српски (Serbian)',
                'su': 'Basa Sunda (Sundanese)',
                'sv': 'Svenska (Swedish)',
                'sw': 'Kiswahili (Swahili)',
                'ta': 'தமிழ் (Tamil)',
                'te': 'తెలుగు (Telugu)',
                'th': 'ไทย (Thai)',
                'tr': 'Türkçe (Turkish)',
                'uk': 'Українська (Ukrainian)',
                'ur': 'اردو (Urdu)',
                'uz': 'Oʻzbekcha (Uzbek)',
                'vi': 'Tiếng Việt (Vietnamese)',
                'zh': '中文 (Chinese)',
                'zh-CN': '中文 (China)',
                'zh-TW': '中文 (Taiwan)',
                'zu': 'isiZulu (Zulu)'
            };

            // Canvas setup
            function resizeCanvas() {
                const rect = canvas.parentElement.getBoundingClientRect();
                canvas.width = rect.width;
                canvas.height = rect.height;
            }
            resizeCanvas();
            window.addEventListener('resize', resizeCanvas);

            function updateCounts() {
                const text = textarea.value;
                charCount.textContent = text.length;
                const words = text.trim() ? text.trim().split(/\s+/).length : 0;
                wordCount.textContent = words;
            }
            textarea.addEventListener('input', function() {
                updateCounts();
                updateHighlight(textarea.value, 0);
                if (!isSpeaking) {
                    waveData = generateWaveData(this.value);
                }
                // Update phonetic based on mode
                if (phoneticDisplayMode === 'translated' && translateResult.value.trim()) {
                    updatePhonetic(translateResult.value);
                } else {
                    updatePhonetic(textarea.value);
                }
                if (parallelPairs.length > 0) {
                    parallelPairs = [];
                    updateParallel();
                }
            });
            updateCounts();

            function updateTranslateCharCount() {
                translateCharCount.textContent = translateResult.value.length;
            }
            translateResult.addEventListener('input', updateTranslateCharCount);
            updateTranslateCharCount();

            function updateHighlight(text, highlightIndex) {
                let html = '';
                const chars = text.split('');
                for (let i = 0; i < chars.length; i++) {
                    const ch = chars[i];
                    if (i === highlightIndex) {
                        html += '<mark class="active">' + escapeHtml(ch) + '</mark>';
                    } else if (i < highlightIndex + 5 && i > highlightIndex - 5) {
                        html += '<mark>' + escapeHtml(ch) + '</mark>';
                    } else {
                        html += escapeHtml(ch);
                    }
                }
                highlightLayer.innerHTML = html;
                highlightLayer.scrollTop = textarea.scrollTop;
                highlightLayer.scrollLeft = textarea.scrollLeft;
            }

            function escapeHtml(str) {
                var div = document.createElement('div');
                div.textContent = str;
                return div.innerHTML;
            }

            textarea.addEventListener('scroll', function() {
                highlightLayer.scrollTop = this.scrollTop;
                highlightLayer.scrollLeft = this.scrollLeft;
            });

            // ============ PARALLEL PHRASE - PER FRASA/KALIMAT PENDEK ============
            function buildParallelPairs(originalText, translatedText) {
                function splitIntoPhrases(text) {
                    let parts = text.match(/[^.!?]+[.!?]+/g);
                    if (!parts) {
                        parts = text.split(/[,;]/).map(s => s.trim()).filter(s => s.length > 0);
                    }
                    if (!parts || parts.length === 0) {
                        return text.trim().split(/\s+/);
                    }
                    return parts.map(s => s.trim());
                }

                const origPhrases = splitIntoPhrases(originalText);
                const transPhrases = splitIntoPhrases(translatedText);

                if (origPhrases.length === 0 || transPhrases.length === 0) {
                    const origWords = originalText.trim().split(/\s+/);
                    const transWords = translatedText.trim().split(/\s+/);
                    const pairs = [];
                    const maxLen = Math.max(origWords.length, transWords.length);
                    for (let i = 0; i < maxLen; i++) {
                        pairs.push({
                            original: i < origWords.length ? origWords[i] : '...',
                            translated: i < transWords.length ? transWords[i] : '...'
                        });
                    }
                    return pairs;
                }

                const pairs = [];
                const maxLen = Math.max(origPhrases.length, transPhrases.length);

                for (let i = 0; i < maxLen; i++) {
                    const orig = i < origPhrases.length ? origPhrases[i] : '';
                    const trans = i < transPhrases.length ? transPhrases[i] : '';
                    if (orig || trans) {
                        pairs.push({
                            original: orig || '...',
                            translated: trans || '...'
                        });
                    }
                }

                return pairs;
            }

            function updateParallel() {
                if (parallelPairs.length === 0) {
                    parallelWrapper.innerHTML = '<span class="parallel-empty">📖 Frasa asli dan terjemahannya akan muncul di sini saat diterjemahkan...</span>';
                    parallelPairCount.textContent = '0 frasa';
                    return;
                }

                let html = '';
                for (let i = 0; i < parallelPairs.length; i++) {
                    const pair = parallelPairs[i];
                    const isActive = (i === parallelActiveIndex);
                    const originalClass = 'original-phrase' + (isActive ? ' active-original' : '');
                    const translatedClass = 'translated-phrase' + (isActive ? ' active-translated' : '');
                    html += '<span class="phrase-pair' + (isActive ? ' active-pair' : '') + '">';
                    html += '<span class="' + originalClass + '">' + escapeHtml(pair.original) + '</span>';
                    html += '<span class="arrow">➜</span>';
                    html += '<span class="' + translatedClass + '">' + escapeHtml(pair.translated) + '</span>';
                    html += '</span>';
                }
                parallelWrapper.innerHTML = html;
                parallelPairCount.textContent = parallelPairs.length + ' frasa';
            }

            function updateParallelPosition(index) {
                parallelActiveIndex = index;
                updateParallel();
            }

            function resetParallel() {
                parallelActiveIndex = -1;
                updateParallel();
            }

            // ============ PHONETIC ============
            function updatePhonetic(text) {
                const words = text.trim() ? text.trim().split(/\s+/) : [];
                currentWords = words;

                if (words.length === 0) {
                    phoneticWrapper.innerHTML = '<span class="phonetic-empty">📖 Kata-kata akan muncul di sini saat suara diputar...</span>';
                    return;
                }

                let html = '';
                for (let w = 0; w < words.length; w++) {
                    const word = words[w];
                    const isActive = (w === currentWordIndex);
                    const chars = word.split('');
                    let wordHtml = '';
                    for (let c = 0; c < chars.length; c++) {
                        const isLetterActive = isActive && (c === currentLetterIndex);
                        wordHtml += '<span class="letter-highlight' + (isLetterActive ? ' active-letter' : '') + '">' + escapeHtml(chars[c]) + '</span>';
                    }
                    html += '<span class="word-chip' + (isActive ? ' active-word' : '') + '">' + wordHtml + '</span>';
                }
                phoneticWrapper.innerHTML = html;
            }

            function updatePhoneticPosition(wordIdx, letterIdx) {
                currentWordIndex = wordIdx;
                currentLetterIndex = letterIdx;
                // Update based on current display mode
                const text = phoneticDisplayMode === 'translated' && translateResult.value.trim() ?
                    translateResult.value :
                    textarea.value;
                updatePhonetic(text);
            }

            function resetPhonetic() {
                currentWordIndex = -1;
                currentLetterIndex = -1;
                const text = phoneticDisplayMode === 'translated' && translateResult.value.trim() ?
                    translateResult.value :
                    textarea.value;
                updatePhonetic(text);
            }

            // Wave Visualizer
            function generateWaveData(text) {
                var data = [];
                var chars = text.split('');
                var totalBars = 80;
                for (var i = 0; i < totalBars; i++) {
                    var charIndex = Math.floor((i / totalBars) * chars.length);
                    var char = chars[charIndex] || ' ';
                    var amplitude = 0.3;
                    if (char.match(/[aeiou]/i)) amplitude = 0.8;
                    else if (char.match(/[bcdfghjklmnpqrstvwxyz]/i)) amplitude = 0.6;
                    else if (char === ' ') amplitude = 0.2;
                    else if (char.match(/[0-9]/)) amplitude = 0.7;
                    else amplitude = 0.5;
                    data.push({
                        amplitude: amplitude,
                        phase: Math.random() * Math.PI * 2,
                        speed: 0.02 + (Math.random() * 0.03)
                    });
                }
                return data;
            }

            function drawWave(time, isActive) {
                var width = canvas.width;
                var height = canvas.height;
                var centerY = height / 2;
                var barWidth = width / waveData.length;

                ctx.clearRect(0, 0, width, height);

                var gradient = ctx.createLinearGradient(0, 0, width, 0);
                gradient.addColorStop(0, 'rgba(124, 58, 237, 0.05)');
                gradient.addColorStop(0.5, 'rgba(124, 58, 237, 0.02)');
                gradient.addColorStop(1, 'rgba(124, 58, 237, 0.05)');
                ctx.fillStyle = gradient;
                ctx.fillRect(0, 0, width, height);

                if (!isActive || !waveData.length) {
                    for (var i = 0; i < 80; i++) {
                        var x = (i / 80) * width;
                        var y = centerY + Math.sin(i * 0.1 + time) * 15;
                        var nextX = ((i + 1) / 80) * width;
                        var nextY = centerY + Math.sin((i + 1) * 0.1 + time) * 15;
                        ctx.beginPath();
                        ctx.moveTo(x, y);
                        ctx.lineTo(nextX, nextY);
                        ctx.strokeStyle = 'rgba(124, 58, 237, 0.15)';
                        ctx.lineWidth = 2;
                        ctx.stroke();
                    }
                    return;
                }

                for (var j = 0; j < waveData.length; j++) {
                    var data = waveData[j];
                    var xPos = (j / waveData.length) * width + barWidth / 2;
                    var amplitude = data.amplitude * (isActive ? 1 : 0.3);
                    var heightMultiplier = isActive ? (0.3 + Math.sin(time * data.speed + data.phase) * 0.2) : 0.2;
                    var barHeight = amplitude * height * heightMultiplier;

                    var hue = 260 + amplitude * 40;
                    var lightness = 50 + amplitude * 30;
                    var alpha = 0.5 + amplitude * 0.3;

                    var glowGradient = ctx.createRadialGradient(
                        xPos, centerY - barHeight / 2, 0,
                        xPos, centerY - barHeight / 2, barHeight * 0.5
                    );
                    glowGradient.addColorStop(0, 'hsla(' + hue + ', 80%, ' + lightness + '%, ' + (alpha * 0.3) + ')');
                    glowGradient.addColorStop(1, 'hsla(' + hue + ', 80%, ' + lightness + '%, 0)');
                    ctx.fillStyle = glowGradient;
                    ctx.fillRect(xPos - barWidth * 0.8, centerY - barHeight, barWidth * 1.6, barHeight * 2);

                    var barGradient = ctx.createLinearGradient(0, centerY - barHeight, 0, centerY + barHeight);
                    barGradient.addColorStop(0, 'hsla(' + hue + ', 90%, 70%, ' + alpha + ')');
                    barGradient.addColorStop(0.5, 'hsla(' + (hue + 20) + ', 80%, 60%, ' + (alpha * 0.8) + ')');
                    barGradient.addColorStop(1, 'hsla(' + (hue - 20) + ', 90%, 70%, ' + alpha + ')');

                    var radius = Math.min(barWidth / 2, 6);
                    var x1 = xPos - barWidth / 2 + 1;
                    var y1 = centerY - barHeight;
                    var w = barWidth - 2;
                    var h = barHeight * 2;

                    ctx.beginPath();
                    ctx.moveTo(x1 + radius, y1);
                    ctx.lineTo(x1 + w - radius, y1);
                    ctx.quadraticCurveTo(x1 + w, y1, x1 + w, y1 + radius);
                    ctx.lineTo(x1 + w, y1 + h - radius);
                    ctx.quadraticCurveTo(x1 + w, y1 + h, x1 + w - radius, y1 + h);
                    ctx.lineTo(x1 + radius, y1 + h);
                    ctx.quadraticCurveTo(x1, y1 + h, x1, y1 + h - radius);
                    ctx.lineTo(x1, y1 + radius);
                    ctx.quadraticCurveTo(x1, y1, x1 + radius, y1);
                    ctx.closePath();
                    ctx.fillStyle = barGradient;
                    ctx.fill();

                    if (barHeight > 5) {
                        ctx.beginPath();
                        var highlightY = centerY - barHeight;
                        ctx.moveTo(x1 + radius, highlightY);
                        ctx.lineTo(x1 + w - radius, highlightY);
                        ctx.quadraticCurveTo(x1 + w, highlightY, x1 + w, highlightY + radius);
                        ctx.strokeStyle = 'hsla(' + hue + ', 100%, 90%, ' + (alpha * 0.3) + ')';
                        ctx.lineWidth = 1;
                        ctx.stroke();
                    }
                }

                ctx.beginPath();
                ctx.moveTo(0, centerY);
                ctx.lineTo(width, centerY);
                ctx.strokeStyle = 'rgba(124, 58, 237, 0.05)';
                ctx.lineWidth = 1;
                ctx.stroke();
            }

            var time = 0;
            var isWaveActive = false;

            function animate() {
                time += 0.02;
                drawWave(time, isWaveActive);
                animationId = requestAnimationFrame(animate);
            }

            function initWaveData() {
                var text = textarea.value || 'Halo';
                waveData = generateWaveData(text);
            }
            initWaveData();
            animate();

            // ============ VOICE LOADING ============
            function forceLoadVoices() {
                var tempVoices = synth.getVoices();
                if (tempVoices && tempVoices.length > 0) {
                    voices = tempVoices;
                    voicesLoaded = true;
                    voiceStatus.style.display = 'none';
                    populateLanguages();
                    return true;
                }
                return false;
            }

            function loadVoicesWithRetry() {
                voiceStatus.style.display = 'block';
                voiceStatus.textContent = '⏳ Memuat suara... (' + (loadAttempts + 1) + '/' + maxLoadAttempts + ')';

                if (forceLoadVoices()) {
                    return;
                }

                loadAttempts++;
                if (loadAttempts < maxLoadAttempts) {
                    setTimeout(loadVoicesWithRetry, 200);
                } else {
                    voiceStatus.textContent = '⚠️ Gagal memuat suara. Silakan refresh halaman.';
                    voiceStatus.style.color = '#ef4444';

                    setTimeout(function() {
                        if (!voicesLoaded) {
                            try {
                                var dummyUtterance = new SpeechSynthesisUtterance(' ');
                                dummyUtterance.volume = 0;
                                synth.speak(dummyUtterance);
                                setTimeout(function() {
                                    synth.cancel();
                                    if (forceLoadVoices()) {
                                        voiceStatus.style.display = 'none';
                                    }
                                }, 200);
                            } catch(e) {}
                        }
                    }, 500);
                }
            }

            function populateLanguages() {
                if (!voices || voices.length === 0) return;

                languageSelect.innerHTML = '';
                voiceSelect.innerHTML = '';

                var langMap = {};
                var voiceMap = {};

                for (var i = 0; i < voices.length; i++) {
                    var voice = voices[i];
                    var langCode = voice.lang;

                    if (!voiceMap[langCode]) {
                        voiceMap[langCode] = [];
                    }
                    voiceMap[langCode].push({
                        index: i,
                        name: voice.name,
                        lang: voice.lang
                    });

                    if (!langMap[langCode]) {
                        langMap[langCode] = true;
                    }
                }

                var sortedLangs = Object.keys(langMap).sort();

                for (var l = 0; l < sortedLangs.length; l++) {
                    var code = sortedLangs[l];
                    var displayName = languageNames[code] || code;
                    var option = document.createElement("option");
                    option.value = code;
                    option.text = displayName + ' (' + code + ')';
                    languageSelect.appendChild(option);
                }

                var defaultLang = 'id-ID';
                var foundDefault = false;
                for (var d = 0; d < languageSelect.options.length; d++) {
                    if (languageSelect.options[d].value === defaultLang) {
                        languageSelect.selectedIndex = d;
                        foundDefault = true;
                        break;
                    }
                }
                if (!foundDefault) {
                    for (var e = 0; e < languageSelect.options.length; e++) {
                        if (languageSelect.options[e].value.indexOf('en') === 0) {
                            languageSelect.selectedIndex = e;
                            foundDefault = true;
                            break;
                        }
                    }
                }
                if (!foundDefault && languageSelect.options.length > 0) {
                    languageSelect.selectedIndex = 0;
                }

                populateVoices(languageSelect.value, voiceMap);
                voiceStatus.style.display = 'none';
                updateButtons();
            }

            function populateVoices(langCode, voiceMap) {
                voiceSelect.innerHTML = "";

                if (!voiceMap) {
                    voiceMap = {};
                    for (var i = 0; i < voices.length; i++) {
                        var voice = voices[i];
                        if (!voiceMap[voice.lang]) {
                            voiceMap[voice.lang] = [];
                        }
                        voiceMap[voice.lang].push({
                            index: i,
                            name: voice.name,
                            lang: voice.lang
                        });
                    }
                }

                var voicesForLang = voiceMap[langCode] || [];

                if (voicesForLang.length === 0) {
                    var option = document.createElement("option");
                    option.value = "";
                    option.text = "Tidak ada suara untuk bahasa ini";
                    voiceSelect.appendChild(option);
                    return;
                }

                voicesForLang.sort(function(a, b) {
                    return a.name.localeCompare(b.name);
                });

                for (var v = 0; v < voicesForLang.length; v++) {
                    var voiceInfo = voicesForLang[v];
                    var option = document.createElement("option");
                    option.value = voiceInfo.index;
                    option.text = voiceInfo.name;
                    voiceSelect.appendChild(option);
                }
            }

            function onLanguageChange() {
                var langCode = languageSelect.value;
                if (!langCode) return;

                var voiceMap = {};
                for (var i = 0; i < voices.length; i++) {
                    var voice = voices[i];
                    if (!voiceMap[voice.lang]) {
                        voiceMap[voice.lang] = [];
                    }
                    voiceMap[voice.lang].push({
                        index: i,
                        name: voice.name,
                        lang: voice.lang
                    });
                }
                populateVoices(langCode, voiceMap);
            }

            if (languageSelect.addEventListener) {
                languageSelect.addEventListener('change', onLanguageChange);
            } else {
                languageSelect.onchange = onLanguageChange;
            }

            var rateInput = document.getElementById("rate");
            var pitchInput = document.getElementById("pitch");
            var volumeInput = document.getElementById("volume");

            rateInput.oninput = function() {
                document.getElementById("rateValue").textContent = this.value + 'x';
            };
            pitchInput.oninput = function() {
                document.getElementById("pitchValue").textContent = this.value;
            };
            volumeInput.oninput = function() {
                document.getElementById("volumeValue").textContent = Math.round(this.value * 100) + '%';
            };

            function setStatus(text, type) {
                statusText.textContent = text;
                statusEl.className = 'status ' + type;
            }

            function updateButtons() {
                var isPlaying = isSpeaking || (synth && synth.speaking);
                var isPausedState = isPaused || (synth && synth.paused);

                playBtn.disabled = isPlaying || !voicesLoaded || voices.length === 0;
                pauseBtn.disabled = !isPlaying || isPausedState || !voicesLoaded || voices.length === 0;
                resumeBtn.disabled = !isPausedState || !voicesLoaded || voices.length === 0;
                stopBtn.disabled = !isPlaying || !voicesLoaded || voices.length === 0;

                if (isPlaying && !isPausedState) {
                    playBtn.classList.add('speaking');
                    playBtn.querySelector('.btn-text').textContent = 'Speaking';
                    playBtn.querySelector('.btn-icon').textContent = '🔊';
                } else {
                    playBtn.classList.remove('speaking');
                    playBtn.querySelector('.btn-text').textContent = 'Speak';
                    playBtn.querySelector('.btn-icon').textContent = '▶';
                }

                const hasTranslateText = translateResult.value.trim().length > 0;
                const isTranslateActive = isTranslateSpeaking || (synth && synth.speaking && translateUtterance);
                playTranslateBtn.disabled = !hasTranslateText || !voicesLoaded || isTranslateActive || voices.length === 0;
                stopTranslateBtn.disabled = !isTranslateActive;
            }

            // ============ TRANSLATE ============
            function translateText() {
                const sourceText = textarea.value.trim();
                if (!sourceText) {
                    setTranslateStatus('⚠️ Masukkan teks terlebih dahulu!', 'error');
                    return;
                }

                const targetLang = translateLang.value;
                const targetLangName = translateLang.options[translateLang.selectedIndex]?.text || targetLang;

                setTranslateStatus('⏳ Menerjemahkan ke ' + targetLangName + '...', 'loading');

                const url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=' + targetLang +
                    '&dt=t&q=' + encodeURIComponent(sourceText);

                fetch(url)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('HTTP error ' + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        let translated = '';
                        if (data && data[0]) {
                            for (let i = 0; i < data[0].length; i++) {
                                if (data[0][i] && data[0][i][0]) {
                                    translated += data[0][i][0];
                                }
                            }
                        }
                        if (translated) {
                            translateResult.value = translated;
                            updateTranslateCharCount();
                            setTranslateStatus('✅ Berhasil diterjemahkan ke ' + targetLangName, 'success');
                            playTranslateBtn.disabled = false;

                            parallelPairs = buildParallelPairs(sourceText, translated);
                            parallelActiveIndex = -1;
                            updateParallel();

                            // Update phonetic based on current display mode
                            const phoneticText = phoneticDisplayMode === 'translated' ? translated : sourceText;
                            updatePhonetic(phoneticText);
                            const words = phoneticText.trim().split(/\s+/);
                            phoneticWordCount.textContent = words.length + ' kata';
                        } else {
                            throw new Error('Hasil terjemahan kosong');
                        }
                        updateButtons();
                    })
                    .catch(error => {
                        console.error('Translation error:', error);
                        setTranslateStatus('❌ Gagal menerjemahkan: ' + error.message, 'error');
                        playTranslateBtn.disabled = true;
                    });
            }

            function setTranslateStatus(text, type) {
                translateStatus.textContent = text;
                translateStatus.className = 'translate-status ' + type;
            }

            // ============ SPEAK TRANSLATE ============
            function speakTranslate() {
                const text = translateResult.value.trim();
                if (!text) {
                    setTranslateStatus('⚠️ Tidak ada teks terjemahan untuk diputar', 'error');
                    return;
                }

                if (!voicesLoaded || voices.length === 0) {
                    setTranslateStatus('⚠️ Suara belum dimuat. Tunggu sebentar...', 'error');
                    forceLoadVoices();
                    setTimeout(function() {
                        if (voicesLoaded) {
                            speakTranslate();
                        }
                    }, 500);
                    return;
                }

                if (synth.speaking) {
                    synth.cancel();
                }

                const utter = new SpeechSynthesisUtterance(text);

                const targetLang = translateLang.value;
                let selectedVoice = null;
                for (let i = 0; i < voices.length; i++) {
                    if (voices[i].lang.startsWith(targetLang)) {
                        selectedVoice = voices[i];
                        break;
                    }
                }
                if (selectedVoice) {
                    utter.voice = selectedVoice;
                    utter.lang = selectedVoice.lang;
                } else {
                    utter.lang = targetLang;
                }

                utter.rate = parseFloat(rateInput.value);
                utter.pitch = parseFloat(pitchInput.value);
                utter.volume = parseFloat(volumeInput.value);

                const originalText = textarea.value.trim();

                utter.onboundary = function(event) {
                    if (event.name === 'word') {
                        const charIndex = event.charIndex || 0;
                        const textCopy = text;
                        let foundWord = false;
                        const wordsArr = textCopy.trim().split(/\s+/);
                        let currentPos = 0;
                        for (let w = 0; w < wordsArr.length; w++) {
                            const word = wordsArr[w];
                            const startPos = currentPos;
                            const endPos = startPos + word.length;
                            if (charIndex >= startPos && charIndex < endPos) {
                                currentWordIndex = w;
                                currentLetterIndex = charIndex - startPos;
                                foundWord = true;

                                const origPhrases = parallelPairs.map(p => p.original);
                                let charCount = 0;
                                for (let p = 0; p < origPhrases.length; p++) {
                                    const phrase = origPhrases[p];
                                    const phraseWords = phrase.trim().split(/\s+/);
                                    const phraseLen = phrase.length;
                                    if (charIndex >= charCount && charIndex < charCount + phraseLen + 1) {
                                        parallelActiveIndex = p;
                                        updateParallel();
                                        break;
                                    }
                                    charCount += phraseLen + 1;
                                }
                                break;
                            }
                            currentPos = endPos + 1;
                        }
                        if (foundWord) {
                            // Use translated text for phonetic display if mode is 'translated'
                            const displayText = phoneticDisplayMode === 'translated' ? text : originalText;
                            const displayWords = displayText.trim().split(/\s+/);
                            if (currentWordIndex < displayWords.length) {
                                const word = displayWords[currentWordIndex];
                                const chars = word.split('');
                                const letterIdx = currentLetterIndex;
                                updatePhoneticPosition(currentWordIndex, letterIdx);
                            }
                        }
                    }
                };

                utter.onstart = function() {
                    isTranslateSpeaking = true;
                    setTranslateStatus('🔊 Memutar terjemahan...', 'loading');
                    playTranslateBtn.disabled = true;
                    stopTranslateBtn.disabled = false;
                    isWaveActive = true;
                    waveData = generateWaveData(text);
                    const displayText = phoneticDisplayMode === 'translated' ? text : originalText;
                    const displayWords = displayText.trim().split(/\s+/);
                    currentWords = displayWords;
                    phoneticWordCount.textContent = displayWords.length + ' kata';
                    updatePhonetic(displayText);
                    parallelActiveIndex = -1;
                    updateParallel();
                    updateButtons();
                };

                utter.onend = function() {
                    isTranslateSpeaking = false;
                    translateUtterance = null;
                    setTranslateStatus('✅ Selesai memutar terjemahan', 'success');
                    playTranslateBtn.disabled = false;
                    stopTranslateBtn.disabled = true;
                    isWaveActive = false;
                    resetPhonetic();
                    resetParallel();
                    updateButtons();
                };

                utter.onerror = function(e) {
                    if (e.error !== 'canceled') {
                        isTranslateSpeaking = false;
                        translateUtterance = null;
                        setTranslateStatus('❌ Error: ' + e.error, 'error');
                        playTranslateBtn.disabled = false;
                        stopTranslateBtn.disabled = true;
                        isWaveActive = false;
                        resetPhonetic();
                        resetParallel();
                        updateButtons();
                    } else {
                        isTranslateSpeaking = false;
                        translateUtterance = null;
                        setTranslateStatus('■ Dihentikan', 'success');
                        playTranslateBtn.disabled = false;
                        stopTranslateBtn.disabled = true;
                        isWaveActive = false;
                        resetPhonetic();
                        resetParallel();
                        updateButtons();
                    }
                };

                translateUtterance = utter;
                synth.speak(utter);
                updateButtons();
            }

            function stopTranslateSpeech() {
                if (synth && (synth.speaking || synth.paused) && translateUtterance) {
                    synth.cancel();
                    isTranslateSpeaking = false;
                    translateUtterance = null;
                    setTranslateStatus('■ Dihentikan', 'success');
                    playTranslateBtn.disabled = false;
                    stopTranslateBtn.disabled = true;
                    isWaveActive = false;
                    resetPhonetic();
                    resetParallel();
                    updateButtons();
                }
            }

            // ============ BUTTON EVENTS ============
            translateBtn.addEventListener('click', translateText);

            clearTranslateBtn.addEventListener('click', function() {
                translateResult.value = '';
                updateTranslateCharCount();
                setTranslateStatus('💡 Hasil terjemahan dibersihkan', '');
                playTranslateBtn.disabled = true;
                stopTranslateBtn.disabled = true;
                if (synth && (synth.speaking || synth.paused) && translateUtterance) {
                    synth.cancel();
                    isTranslateSpeaking = false;
                    translateUtterance = null;
                    isWaveActive = false;
                }
                resetPhonetic();
                parallelPairs = [];
                resetParallel();
                updateButtons();
            });

            playTranslateBtn.addEventListener('click', speakTranslate);
            stopTranslateBtn.addEventListener('click', stopTranslateSpeech);

            document.addEventListener('keydown', function(e) {
                if ((e.ctrlKey || e.metaKey) && e.key === 't') {
                    e.preventDefault();
                    translateBtn.click();
                }
            });

            // ============ SPEAK TEXT ============
            function speakText() {
                if (synth && synth.speaking) {
                    synth.cancel();
                }

                var text = document.getElementById("text").value;
                if (!text.trim()) {
                    setStatus('Mohon masukkan teks terlebih dahulu!', 'error');
                    updateButtons();
                    return;
                }

                if (!voicesLoaded || voices.length === 0) {
                    setStatus('⚠️ Suara belum dimuat. Tunggu sebentar...', 'error');
                    forceLoadVoices();
                    setTimeout(function() {
                        if (voicesLoaded) {
                            speakText();
                        }
                    }, 500);
                    return;
                }

                waveData = generateWaveData(text);
                isWaveActive = true;

                var utter = new SpeechSynthesisUtterance(text);
                var selectedVoiceIndex = parseInt(voiceSelect.value);

                if (!isNaN(selectedVoiceIndex) && voices[selectedVoiceIndex]) {
                    var selectedVoice = voices[selectedVoiceIndex];
                    utter.voice = selectedVoice;
                    utter.lang = selectedVoice.lang;
                } else if (languageSelect.value) {
                    utter.lang = languageSelect.value;
                }

                utter.rate = parseFloat(rateInput.value);
                utter.pitch = parseFloat(pitchInput.value);
                utter.volume = parseFloat(volumeInput.value);

                const displayText = phoneticDisplayMode === 'translated' && translateResult.value.trim() ?
                    translateResult.value :
                    text;
                const displayWords = displayText.trim().split(/\s+/);
                currentWords = displayWords;
                phoneticWordCount.textContent = displayWords.length + ' kata';
                updatePhonetic(displayText);

                utter.onboundary = function(event) {
                    if (event.name === 'word' || event.name === 'sentence') {
                        const charIndex = event.charIndex || 0;
                        updateHighlight(text, charIndex);

                        let foundWord = false;
                        const wordsArr = text.trim().split(/\s+/);
                        let currentPos = 0;
                        for (let w = 0; w < wordsArr.length; w++) {
                            const word = wordsArr[w];
                            const startPos = currentPos;
                            const endPos = startPos + word.length;
                            if (charIndex >= startPos && charIndex < endPos) {
                                currentWordIndex = w;
                                currentLetterIndex = charIndex - startPos;
                                foundWord = true;
                                break;
                            }
                            currentPos = endPos + 1;
                        }
                        if (foundWord) {
                            const displayTextForPhonetic = phoneticDisplayMode === 'translated' && translateResult.value.trim() ?
                                translateResult.value :
                                text;
                            const displayWordsArr = displayTextForPhonetic.trim().split(/\s+/);
                            if (currentWordIndex < displayWordsArr.length) {
                                const word = displayWordsArr[currentWordIndex];
                                const chars = word.split('');
                                const letterIdx = currentLetterIndex;
                                updatePhoneticPosition(currentWordIndex, letterIdx);
                            }
                            if (currentWordIndex < parallelPairs.length) {
                                const origPhrases = parallelPairs.map(p => p.original);
                                let charCount = 0;
                                for (let p = 0; p < origPhrases.length; p++) {
                                    const phrase = origPhrases[p];
                                    const phraseWords = phrase.trim().split(/\s+/);
                                    const phraseLen = phrase.length;
                                    if (charIndex >= charCount && charIndex < charCount + phraseLen + 1) {
                                        parallelActiveIndex = p;
                                        updateParallel();
                                        break;
                                    }
                                    charCount += phraseLen + 1;
                                }
                            }
                        }

                        if (charIndex < text.length) {
                            for (var idx = 0; idx < waveData.length; idx++) {
                                var charIdx = Math.floor((idx / waveData.length) * text.length);
                                if (charIdx === charIndex) {
                                    waveData[idx].amplitude = 1.0;
                                } else if (Math.abs(charIdx - charIndex) < 3) {
                                    waveData[idx].amplitude = 0.7;
                                } else {
                                    var origData = generateWaveData(text);
                                    var origAmp = origData[idx] ? origData[idx].amplitude : 0.3;
                                    waveData[idx].amplitude = origAmp * 0.5;
                                }
                            }
                        }
                    }
                };

                utter.onstart = function() {
                    setStatus('🎤 Sedang berbicara...', 'speaking');
                    isSpeaking = true;
                    isPaused = false;
                    isWaveActive = true;
                    updateHighlight(text, 0);
                    const displayTextForPhonetic = phoneticDisplayMode === 'translated' && translateResult.value.trim() ?
                        translateResult.value :
                        text;
                    updatePhonetic(displayTextForPhonetic);
                    updateButtons();
                };

                utter.onpause = function() {
                    setStatus('⏸ Pause', 'paused');
                    isPaused = true;
                    isWaveActive = false;
                    updateButtons();
                };

                utter.onresume = function() {
                    setStatus('▶ Melanjutkan...', 'speaking');
                    isPaused = false;
                    isWaveActive = true;
                    updateButtons();
                };

                utter.onend = function() {
                    setStatus('✅ Selesai', 'done');
                    isSpeaking = false;
                    isPaused = false;
                    isWaveActive = false;
                    updateButtons();
                    waveData = generateWaveData(text);
                    updateHighlight(text, -1);
                    resetPhonetic();
                    resetParallel();
                };

                utter.onerror = function(e) {
                    if (e.error !== 'canceled') {
                        setStatus('❌ Error: ' + e.error, 'error');
                        isSpeaking = false;
                        isPaused = false;
                        isWaveActive = false;
                        updateButtons();
                        waveData = generateWaveData(text);
                        resetPhonetic();
                        resetParallel();
                    } else {
                        isSpeaking = false;
                        isPaused = false;
                        isWaveActive = false;
                        setStatus('■ Dihentikan', 'ready');
                        updateButtons();
                        waveData = generateWaveData(text);
                        updateHighlight(text, -1);
                        resetPhonetic();
                        resetParallel();
                    }
                };

                currentUtterance = utter;
                if (synth) {
                    synth.speak(utter);
                }
            }

            document.getElementById("play").onclick = function() {
                if (synth && synth.speaking && !synth.paused) {
                    return;
                }
                speakText();
            };

            document.getElementById("pause").onclick = function() {
                if (synth && synth.speaking && !synth.paused) {
                    synth.pause();
                    setStatus('⏸ Pause', 'paused');
                    isPaused = true;
                    isWaveActive = false;
                    updateButtons();
                } else if (!synth || !synth.speaking) {
                    setStatus('⚠️ Tidak ada suara yang diputar', 'error');
                    setTimeout(function() { setStatus('Siap', 'ready'); }, 1500);
                }
            };

            document.getElementById("resume").onclick = function() {
                if (synth && synth.paused) {
                    synth.resume();
                    setStatus('▶ Melanjutkan...', 'speaking');
                    isPaused = false;
                    isWaveActive = true;
                    updateButtons();
                } else if (!synth || !synth.speaking) {
                    setStatus('⚠️ Tidak ada suara yang dipause', 'error');
                    setTimeout(function() { setStatus('Siap', 'ready'); }, 1500);
                }
            };

            document.getElementById("stop").onclick = function() {
                if (synth && synth.speaking) {
                    synth.cancel();
                    setStatus('■ Dihentikan', 'ready');
                    isSpeaking = false;
                    isPaused = false;
                    isWaveActive = false;
                    updateButtons();
                    waveData = generateWaveData(textarea.value);
                    updateHighlight(textarea.value, -1);
                    resetPhonetic();
                    resetParallel();
                } else {
                    setStatus('⚠️ Tidak ada suara yang diputar', 'error');
                    setTimeout(function() { setStatus('Siap', 'ready'); }, 1500);
                }
            };

            document.addEventListener('keydown', function(e) {
                if (e.ctrlKey || e.metaKey) {
                    switch (e.key) {
                        case 'Enter':
                            e.preventDefault();
                            if (!synth || !synth.speaking || (synth && synth.paused)) {
                                document.getElementById('play').click();
                            }
                            break;
                        case ' ':
                            e.preventDefault();
                            if (synth && synth.paused) {
                                document.getElementById('resume').click();
                            } else if (synth && synth.speaking) {
                                document.getElementById('pause').click();
                            }
                            break;
                        case 's':
                            e.preventDefault();
                            document.getElementById('stop').click();
                            break;
                    }
                }
            });

            // Initialize
            updateButtons();
            setStatus('Siap', 'ready');
            updateHighlight(textarea.value, -1);
            updatePhonetic(textarea.value);
            updateParallel();

            initVoices();

            window.addEventListener('beforeunload', function() {
                if (animationId) cancelAnimationFrame(animationId);
                if (synth && synth.speaking) synth.cancel();
            });

            window.addEventListener('focus', function() {
                if (!voicesLoaded) {
                    forceLoadVoices();
                    if (!voicesLoaded) {
                        loadVoicesWithRetry();
                    }
                }
            });

            function initVoices() {
                if (forceLoadVoices()) {
                    return;
                }

                if (synth.onvoiceschanged !== undefined) {
                    synth.onvoiceschanged = function() {
                        if (forceLoadVoices()) {
                            synth.onvoiceschanged = null;
                        }
                    };
                }

                loadVoicesWithRetry();

                setTimeout(function() {
                    if (!voicesLoaded) {
                        try {
                            var dummy = new SpeechSynthesisUtterance(' ');
                            dummy.volume = 0;
                            synth.speak(dummy);
                            setTimeout(function() {
                                synth.cancel();
                                if (!voicesLoaded) {
                                    forceLoadVoices();
                                }
                            }, 200);
                        } catch(e) {}
                    }
                }, 1000);
            }

        })();
