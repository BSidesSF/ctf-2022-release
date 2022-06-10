window.addEventListener('DOMContentLoaded', function() {
    const crypto = window.crypto;
    const toHexString = (bytes) =>
        bytes.reduce((str, byte) =>
            str + byte.toString(16).padStart(2, '0'), '');
    const tsNow = () => (new Date()).getTime();
    window.toHexString = toHexString;
    const compute_proofofwork = async function(input, difficulty) {
        const started = tsNow();
        const rngdata = new Uint8Array(16);
        const encoder = new TextEncoder();
        const inputData = encoder.encode(input);
        const blk = new Uint8Array(rngdata.byteLength + inputData.byteLength);
        blk.set(inputData, 0);
        while (1) {
            crypto.getRandomValues(rngdata);
            blk.set(rngdata, inputData.byteLength);
            const rawHash = await crypto.subtle.digest("SHA-256", blk);
            const strHash = toHexString(new Uint8Array(rawHash));
            let match = true;
            for(let i=0;i<difficulty;i++) {
                match = match && strHash[i] == '0';
            }
            if (match) {
                break;
            }
        };
        const finished = tsNow();
        console.log('Proof of work took: ' + (finished - started) + ' ms');
        return toHexString(rngdata);
    };
    window.compute_pow = compute_proofofwork;
    const subBtn = document.getElementById('new-message-submit');
    if (subBtn) {
        subBtn.addEventListener('click', async (evt) => {
            evt.preventDefault();
            const formData = new FormData(document.getElementById('new-message'));
            const body = formData.get('message');
            const difficulty = parseInt(formData.get('difficulty') || '4');
            formData.set('pow', await compute_proofofwork(body, difficulty));
            const resp = await fetch('/message', {
                'method': 'POST',
                'body': formData,
            });
            const respBody = await resp.text();
            document.open('text/html');
            document.write(respBody);
            document.close();
        });
    }
});
