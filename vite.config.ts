import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  // A relative base keeps assets working both on a user site and in a
  // repository subfolder such as https://user.github.io/grs-vision/.
  base: './',
  plugins: [react()],
  build: { target: 'es2022', sourcemap: true },
})
