import { defineConfig, loadEnv } from "vite";
import laravel from "laravel-vite-plugin";

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, process.cwd());

    return {
        base: env.ASSET_URL ? `${env.ASSET_URL}/` : "/",
        plugins: [
            laravel({
                input: ["resources/css/app.css", "resources/js/app.js"],
                refresh: true,
            }),
        ],
    };
});
