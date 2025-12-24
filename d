<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>محمل يوتيوب</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 text-white min-h-screen">
    <div class="container mx-auto px-4 py-12">
        <!-- Header -->
        <div class="text-center mb-12">
            <h1 class="text-5xl font-bold mb-4">🎥 محمل يوتيوب</h1>
            <p class="text-xl text-gray-300">حمّل الفيديوهات والصوتيات من يوتيوب بجودة عالية</p>
        </div>

        <!-- Main Card -->
        <div class="max-w-4xl mx-auto bg-white/10 backdrop-blur-lg rounded-2xl p-8 shadow-2xl">
            <!-- Input Section -->
            <div class="mb-6">
                <label class="block text-lg font-semibold mb-3">🔗 الصق رابط يوتيوب هنا</label>
                <div class="flex gap-3">
                    <input 
                        type="text" 
                        id="videoUrl"
                        placeholder="https://www.youtube.com/watch?v=..."
                        class="flex-1 px-4 py-3 bg-white/20 border border-white/30 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-white placeholder-gray-400"
                        dir="ltr"
                    />
                    <button 
                        onclick="fetchVideo()"
                        id="fetchBtn"
                        class="px-6 py-3 bg-red-600 hover:bg-red-700 rounded-lg font-bold transition-colors">
                        جلب الفيديو
                    </button>
                </div>
            </div>

            <!-- Error Message -->
            <div id="errorMsg" class="hidden mb-6 p-4 bg-red-500/20 border border-red-500 rounded-lg">
                <span id="errorText"></span>
            </div>

            <!-- Loading -->
            <div id="loading" class="hidden text-center py-8">
                <div class="inline-block w-12 h-12 border-4 border-white border-t-transparent rounded-full animate-spin"></div>
                <p class="mt-4">جاري جلب معلومات الفيديو...</p>
            </div>

            <!-- Result Section -->
            <div id="result" class="hidden mt-8 space-y-6">
                <!-- Video Info -->
                <div class="p-6 bg-white/10 rounded-xl">
                    <div class="flex gap-4 mb-4">
                        <img id="thumbnail" class="w-40 h-24 object-cover rounded-lg" />
                        <div class="flex-1">
                            <h3 id="title" class="text-xl font-bold mb-2"></h3>
                            <p id="channel" class="text-gray-300 text-sm mb-1"></p>
                            <p id="duration" class="text-gray-300 text-sm"></p>
                        </div>
                    </div>
                </div>

                <!-- Video Downloads -->
                <div id="videosSection" class="p-6 bg-white/10 rounded-xl">
                    <h4 class="text-xl font-bold mb-4">📹 تحميل الفيديو</h4>
                    <div id="videosList" class="space-y-3"></div>
                </div>

                <!-- Audio Downloads -->
                <div id="audiosSection" class="p-6 bg-white/10 rounded-xl">
                    <h4 class="text-xl font-bold mb-4">🎵 تحميل الصوت فقط (MP3)</h4>
                    <div id="audiosList" class="space-y-3"></div>
                </div>
            </div>

            <!-- Instructions -->
            <div class="mt-8 pt-6 border-t border-white/20">
                <h3 class="text-lg font-semibold mb-3">كيفية الاستخدام:</h3>
                <ol class="list-decimal list-inside space-y-2 text-gray-300">
                    <li>انسخ رابط فيديو يوتيوب</li>
                    <li>الصق الرابط في الحقل أعلاه</li>
                    <li>اضغط على "جلب الفيديو"</li>
                    <li>اختر الجودة المناسبة واضغط على زر التحميل</li>
                </ol>
            </div>
        </div>
    </div>

    <script>
        // استخراج ID من رابط يوتيوب
        function extractYouTubeId(url) {
            const patterns = [
                /(?:youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})/,
                /(?:youtu\.be\/)([a-zA-Z0-9_-]{11})/,
                /(?:youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})/
            ];
            
            for (let pattern of patterns) {
                const match = url.match(pattern);
                if (match && match[1]) return match[1];
            }
            return null;
        }

        // جلب معلومات الفيديو
        async function fetchVideo() {
            const url = document.getElementById('videoUrl').value.trim();
            const errorMsg = document.getElementById('errorMsg');
            const errorText = document.getElementById('errorText');
            const loading = document.getElementById('loading');
            const result = document.getElementById('result');
            const fetchBtn = document.getElementById('fetchBtn');

            // إخفاء الرسائل السابقة
            errorMsg.classList.add('hidden');
            result.classList.add('hidden');

            if (!url) {
                errorText.textContent = 'الرجاء إدخال رابط الفيديو';
                errorMsg.classList.remove('hidden');
                return;
            }

            const videoId = extractYouTubeId(url);
            if (!videoId) {
                errorText.textContent = 'رابط يوتيوب غير صحيح';
                errorMsg.classList.remove('hidden');
                return;
            }

            // عرض التحميل
            loading.classList.remove('hidden');
            fetchBtn.disabled = true;
            fetchBtn.textContent = 'جاري التحميل...';

            try {
                const response = await fetch(
                    `https://youtube-media-downloader.p.rapidapi.com/v2/video/details?videoId=${videoId}&urlAccess=normal&videos=auto&audios=auto`,
                    {
                        method: 'GET',
                        headers: {
                            'x-rapidapi-host': 'youtube-media-downloader.p.rapidapi.com',
                            'x-rapidapi-key': 'ebe8cb9d63msh6b4d129f6df7584p1faa2cjsnc9de3f8899d6'
                        }
                    }
                );

                if (!response.ok) {
                    throw new Error('فشل في جلب معلومات الفيديو');
                }

                const data = await response.json();
                console.log('API Response:', data);

                // عرض النتائج
                displayResults(data);
                result.classList.remove('hidden');

            } catch (error) {
                console.error('Error:', error);
                errorText.textContent = 'حدث خطأ: ' + error.message;
                errorMsg.classList.remove('hidden');
            } finally {
                loading.classList.add('hidden');
                fetchBtn.disabled = false;
                fetchBtn.textContent = 'جلب الفيديو';
            }
        }

        // عرض النتائج
        function displayResults(data) {
            // معلومات الفيديو
            document.getElementById('title').textContent = data.title || 'فيديو يوتيوب';
            document.getElementById('thumbnail').src = data.thumbnail || data.thumbnails?.[0]?.url || '';
            document.getElementById('channel').textContent = 'القناة: ' + (data.channel?.name || data.author || 'غير معروف');
            document.getElementById('duration').textContent = 'المدة: ' + (data.lengthText || data.duration || 'غير معروف');

            // قائمة الفيديوهات
            const videosList = document.getElementById('videosList');
            videosList.innerHTML = '';
            if (data.videos && data.videos.length > 0) {
                data.videos.forEach((video, idx) => {
                    const btn = createDownloadButton(
                        video.quality || `جودة ${idx + 1}`,
                        video.url,
                        video.size,
                        'bg-blue-600 hover:bg-blue-700'
                    );
                    videosList.appendChild(btn);
                });
                document.getElementById('videosSection').classList.remove('hidden');
            } else {
                document.getElementById('videosSection').classList.add('hidden');
            }

            // قائمة الصوتيات
            const audiosList = document.getElementById('audiosList');
            audiosList.innerHTML = '';
            if (data.audios && data.audios.length > 0) {
                data.audios.forEach((audio, idx) => {
                    const btn = createDownloadButton(
                        audio.quality || `جودة ${idx + 1}`,
                        audio.url,
                        audio.size,
                        'bg-green-600 hover:bg-green-700'
                    );
                    audiosList.appendChild(btn);
                });
                document.getElementById('audiosSection').classList.remove('hidden');
            } else {
                document.getElementById('audiosSection').classList.add('hidden');
            }
        }

        // إنشاء زر تحميل
        function createDownloadButton(quality, url, size, colorClass) {
            const btn = document.createElement('button');
            btn.onclick = () => window.open(url, '_blank');
            btn.className = `w-full px-4 py-3 ${colorClass} rounded-lg font-semibold transition-colors flex items-center justify-between`;
            
            let sizeText = '';
            if (size) {
                const mb = (size / (1024 * 1024)).toFixed(2);
                sizeText = `<span class="text-sm text-gray-200">${mb} MB</span>`;
            }
            
            btn.innerHTML = `
                <span>${quality}</span>
                <div class="flex items-center gap-3">
                    ${sizeText}
                    <span>⬇️</span>
                </div>
            `;
            return btn;
        }

        // Enter key support
        document.getElementById('videoUrl').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') fetchVideo();
        });
    </script>
</body>
</html>
