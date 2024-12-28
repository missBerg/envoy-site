document.addEventListener('DOMContentLoaded', function () {
    const CACHE_DURATION = 3600 * 1000; // 1 hour in milliseconds
    const projects = document.querySelectorAll('[id^="github-stars-"]');

    projects.forEach((element) => {
        const repo = element.id.replace('github-stars-', 'envoyproxy/');
        const cacheKey = `github-stars-${repo}`;
        const cacheTimestampKey = `${cacheKey}-timestamp`;
        const cachedStars = localStorage.getItem(cacheKey);
        const cachedTimestamp = localStorage.getItem(cacheTimestampKey);

        // Check if cache is valid
        if (cachedStars && cachedTimestamp && Date.now() - cachedTimestamp < CACHE_DURATION) {
            element.textContent = cachedStars; // Use cached data
        } else {
            // Fetch from GitHub API
            const apiUrl = `https://api.github.com/repos/${repo}`;
            fetch(apiUrl)
                .then(response => response.json())
                .then(data => {
                    const stars = data.stargazers_count;
                    element.textContent = stars;

                    // Cache the data
                    localStorage.setItem(cacheKey, stars);
                    localStorage.setItem(cacheTimestampKey, Date.now());
                })
                .catch(error => {
                    console.error(`Error fetching stars for ${repo}:`, error);
                    element.textContent = 'Error'; // Fallback in case of error
                });
        }
    });
});
