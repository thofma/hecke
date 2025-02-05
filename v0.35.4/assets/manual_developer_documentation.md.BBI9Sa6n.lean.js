import{_ as e,c as t,a4 as a,o as s}from"./chunks/framework.DBNiZrUx.js";const u=JSON.parse('{"title":"Documentation","description":"","frontmatter":{},"headers":[],"relativePath":"manual/developer/documentation.md","filePath":"manual/developer/documentation.md","lastUpdated":null}'),n={name:"manual/developer/documentation.md"};function o(l,i,d,h,p,c){return s(),t("div",null,i[0]||(i[0]=[a(`<h1 id="documentation" tabindex="-1">Documentation <a class="header-anchor" href="#documentation" aria-label="Permalink to &quot;Documentation&quot;">​</a></h1><p>The files for the documentation are located in the <code>docs/src/manual/</code> directory.</p><h2 id="Adding-files-to-the-documentation" tabindex="-1">Adding files to the documentation <a class="header-anchor" href="#Adding-files-to-the-documentation" aria-label="Permalink to &quot;Adding files to the documentation {#Adding-files-to-the-documentation}&quot;">​</a></h2><p>To add files to the documentation edit directly the file <code>docs/src/.vitepress/config.mts</code>.</p><h2 id="Building-the-documentation" tabindex="-1">Building the documentation <a class="header-anchor" href="#Building-the-documentation" aria-label="Permalink to &quot;Building the documentation {#Building-the-documentation}&quot;">​</a></h2><ol><li>Run julia and execute (with Hecke developed in your current environment)</li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">julia</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Hecke</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">julia</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">&gt;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Hecke</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">build_doc</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">() </span><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># or Hecke.build_doc(;doctest = false) to speed things up</span></span></code></pre></div><ol><li>In the terminal, navigate to <code>docs/</code> and run</li></ol><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">Hecke/docs</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt; </span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">npm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> run</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> docs:build</span></span></code></pre></div><p>(This step takes place outside of julia.)</p><div class="tip custom-block"><p class="custom-block-title">Note</p><p>To speed up the development process, step 1 can be repeated within the same julia session.</p></div>`,11)]))}const k=e(n,[["render",o]]);export{u as __pageData,k as default};
