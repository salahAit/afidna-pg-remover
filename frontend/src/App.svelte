<script>
  let originalImage = $state(null);
  let processedImage = $state(null);
  let loading = $state(false);
  let error = $state(null);
  let fileInput;

  function handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
      processFile(file);
    }
  }

  function handleDrop(event) {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (file) {
      processFile(file);
    }
  }

  function handleDragOver(event) {
    event.preventDefault();
  }

  function processFile(file) {
    error = null;
    processedImage = null;
    originalImage = URL.createObjectURL(file);
    uploadImage(file);
  }

  async function uploadImage(file) {
    loading = true;
    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await fetch('http://localhost:8000/remove', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        throw new Error('فشل في معالجة الصورة');
      }

      const blob = await response.blob();
      processedImage = URL.createObjectURL(blob);
    } catch (err) {
      console.error(err);
      error = "حدث خطأ أثناء معالجة الصورة. تأكد من تشغيل الخادم.";
    } finally {
      loading = false;
    }
  }

  function downloadImage() {
    if (!processedImage) return;
    const a = document.createElement('a');
    a.href = processedImage;
    a.download = 'removed-background.png';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  function reset() {
    originalImage = null;
    processedImage = null;
    error = null;
    if (fileInput) fileInput.value = '';
  }
</script>

<main>
  <div class="header">
    <img src="/hadif-logo.webp" alt="أفيدنا" class="logo" />
    <h1>مزيل الخلفية</h1>
  </div>
  
  <div class="container">
    <!-- Input Section -->
    <div 
      class="upload-zone"
      ondrop={handleDrop}
      ondragover={handleDragOver}
      role="region"
      aria-label="منطقة سحب وإفلات الملفات"
    >
      {#if !originalImage}
        <div class="placeholder">
          <p>اسحب وأفلت الصورة هنا</p>
          <p>أو</p>
          <button onclick={() => fileInput.click()}>اختر ملفاً</button>
          <input 
            type="file" 
            accept="image/*" 
            bind:this={fileInput} 
            onchange={handleFileSelect} 
            hidden 
          />
        </div>
      {:else}
        <div class="image-preview">
          <h3>الأصلية</h3>
          <img src={originalImage} alt="الأصلية" />
          <button class="secondary" onclick={reset}>رفع صورة أخرى</button>
        </div>
      {/if}
    </div>

    <!-- Output Section -->
    <div class="result-zone">
      {#if loading}
        <div class="loading">
          <div class="spinner"></div>
          <p>جاري إزالة الخلفية...</p>
        </div>
      {:else if processedImage}
        <div class="image-preview">
          <h3>النتيجة</h3>
          <div class="checkerboard">
            <img src={processedImage} alt="النتيجة" />
          </div>
          <button onclick={downloadImage}>تحميل الصورة (PNG)</button>
        </div>
      {:else if error}
        <div class="error">
          <p>{error}</p>
          <button onclick={() => processFile(fileInput.files[0])}>حاول مرة أخرى</button>
        </div>
      {:else}
        <div class="placeholder empty-state">
          <p>ستظهر الصورة المعالجة هنا</p>
        </div>
      {/if}
    </div>
  </div>
</main>

<style>
  main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }

  .header {
    text-align: center;
    margin-bottom: 2rem;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }

  .logo {
    max-height: 120px;
    object-fit: contain;
  }

  h1 {
    margin: 0;
  }

  .container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
    align-items: start;
  }

  @media (max-width: 768px) {
    .container {
      grid-template-columns: 1fr;
    }
  }

  .upload-zone, .result-zone {
    background: #2a2a2a;
    border-radius: 12px;
    padding: 1rem;
    min-height: 400px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    border: 2px dashed #444;
  }

  .upload-zone:hover {
    border-color: #646cff;
  }

  .placeholder {
    text-align: center;
    color: #888;
  }

  .image-preview {
    width: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }

  .image-preview img {
    max-width: 100%;
    max-height: 400px;
    object-fit: contain;
    border-radius: 8px;
  }

  .checkerboard {
    background-color: #eee;
    background-image:
      linear-gradient(45deg, #ccc 25%, transparent 25%),
      linear-gradient(-45deg, #ccc 25%, transparent 25%),
      linear-gradient(45deg, transparent 75%, #ccc 75%),
      linear-gradient(-45deg, transparent 75%, #ccc 75%);
    background-size: 20px 20px;
    background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
    border-radius: 8px;
    width: 100%;
    display: flex;
    justify-content: center;
  }

  .loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }

  .spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #646cff;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .error {
    color: #ff6b6b;
    text-align: center;
  }

  button {
    background-color: #646cff;
    color: white;
    border-radius: 8px;
    border: 1px solid transparent;
    padding: 0.6em 1.2em;
    font-size: 1em;
    font-weight: 500;
    font-family: inherit;
    cursor: pointer;
    transition: border-color 0.25s;
  }

  button:hover {
    background-color: #535bf2;
  }

  button:focus,
  button:focus-visible {
    outline: 4px auto -webkit-focus-ring-color;
  }

  button.secondary {
    background-color: #444;
  }
  
  button.secondary:hover {
    background-color: #555;
  }
</style>
