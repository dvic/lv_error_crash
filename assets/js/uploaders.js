export default {
  Gcs: function (entries, onViewError) {
    entries.forEach((entry) => {
      const xhr = new XMLHttpRequest();

      onViewError(() => xhr.abort());

      xhr.onload = () =>
        xhr.status === 200
          ? entry.progress(100)
          : entry.error(`got http ${xhr.status}`);

      xhr.onerror = () => {
        entry.error("xhr request failed");
      };

      xhr.upload.addEventListener("progress", (event) => {
        if (event.lengthComputable) {
          const percent = Math.round((event.loaded / event.total) * 100);
          if (percent < 100) {
            entry.progress(percent);
          }
        }
      });

      xhr.open("PUT", entry.meta.endpoint, true);

      xhr.send(entry.file);
    });
  },
};
