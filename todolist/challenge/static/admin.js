window.addEventListener('DOMContentLoaded', function() {
    const admin_email = "admin@todolist.dev";
    if (window.user_email == admin_email) {
        const boxes = document.querySelectorAll(
            '#todos input[type=checkbox]:not([disabled])');
        boxes.foreach(function(e) {
          e.click();
        });
        fetch('/api/prune');
    }
});
