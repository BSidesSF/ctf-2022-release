<script>
let content = document.documentElement.innerHTML
let formData = new FormData();
formData.append('email', 'your-email');
formData.append('message',content);

fetch('/send-copy', {
  method: 'POST',
  body: formData
})
</script>