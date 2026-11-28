# gptcopilot.nvim v3

Asistente de código multi-proveedor para Neovim, implementado en Lua y pensado para Termux. Conserva el nombre del proyecto original. Esta versión separa el núcleo del proveedor y añade prompts desde comentarios, debounce de 3 segundos, contexto de archivos, caché y keymaps granulares.

## Compatibilidad y dependencias

- Neovim 0.10+ con LuaJIT y `vim.json` (usa virtual text inline para ghost text).
- `curl` disponible en Termux (`pkg install neovim curl`).
- No requiere Node.js, Python, npm, compiladores, `jq`, `plenary.nvim` ni procesos auxiliares.
- Los proveedores se consultan mediante HTTP REST desde `curl`.

## Instalación

Con lazy.nvim:

```lua
{
  dir = "~/projects/gptcopilot.nvim",
  name = "gptcopilot.nvim",
  config = function()
    require("gptcopilot").setup({})
  end,
}
```

## Proveedores y modelos

Proveedor y modelo predeterminados: `openai` y `gpt-6.2-astra`. El modelo se puede cambiar por cualquier ID habilitado en la cuenta. Configura las claves en el entorno antes de iniciar Neovim:

```sh
export OPENAI_API_KEY='...'
export GEMINI_API_KEY='...'
export DEEPSEEK_API_KEY='...'
```

- OpenAI: Chat Completions REST (`/v1/chat/completions`), autenticación Bearer.
- DeepSeek: protocolo Chat Completions compatible, URL base `https://api.deepseek.com`.
- Gemini: REST nativo `models/{model}:generateContent`, cabecera `x-goog-api-key`.

Cambiar durante la sesión:

```vim
:GPTCopilotProvider gemini
:GPTCopilotModel gemini-2.5-flash
:GPTCopilotProvider deepseek
:GPTCopilotModel deepseek-v4-pro
:GPTCopilotProvider openai
```

Añadir un proveedor OpenAI-compatible durante la sesión:

```vim
:GPTCopilotAddProvider {"name":"mi-api","protocol":"openai","base_url":"https://host.example/v1","api_key_env":"MI_API_KEY","model":"modelo-x"}
:GPTCopilotProvider mi-api
```

El proveedor personalizado debe aceptar `POST /chat/completions`, mensajes `system`/`user` y devolver `choices[0].message.content`. El protocolo `gemini` se reserva para el formato REST nativo de Gemini. El proveedor personalizado agregado por comando vive durante la sesión; para persistirlo, decláralo en `setup()` dentro de `providers`.

## Autocompletado y prompts desde comentarios

El debounce es **3000 ms**. Cada evento de escritura o movimiento reinicia el temporizador; si no hay otro evento durante 3 segundos, se envía una petición. El plugin primero busca un bloque de comentarios contiguo inmediatamente encima del cursor. Si lo encuentra, usa ese texto como instrucción. Si no lo encuentra y `auto_trigger=true`, solicita continuación de código.

Ejemplos reconocidos:

```lua
-- Añade un mensaje de espera con animación
```

```php
// Crea una clase para el modelo de factura
```

```sql
--- Modifica la consulta eliminando el join a la tabla colores
```

```dart
/*
 * Lee el archivo ia/rules.md y genera una clase para implementar sqlite
 */
```

La extracción utiliza primero el `commentstring` de Neovim y complementa con prefijos habituales `//`, `#`, `--`, `/*`, `*`, `*/`, `;`, `%` y delimitadores HTML. No depende de una lista cerrada de extensiones. Los comentarios deben estar inmediatamente encima de la posición del cursor (se toleran líneas vacías entre el bloque y el cursor). El código sugerido se muestra como ghost text y no se inserta hasta que el usuario lo acepte.

## Keymaps predeterminados

En modo inserción:

| Tecla | Acción |
|---|---|
| `Ctrl+Right` | Aceptar una palabra |
| `Ctrl+End` | Aceptar la línea actual |
| `Ctrl+Down` | Aceptar toda la sugerencia |
| `Ctrl+Space` | Ocultar sugerencia |

Configúralos en `setup()`:

```lua
require("gptcopilot").setup({
  keymap = {
    accept_word = "<C-Right>",
    accept_line = "<C-End>",
    accept_all = "<C-Down>",
    hide = "<C-Space>",
  },
})
```

Algunos teclados Android/terminales no transmiten todas las combinaciones Ctrl+flecha/End de forma diferenciada. En ese caso asigna otras teclas; no es una limitación de la API de IA.

## Contexto

Cada petición incluye el prompt, el contenido completo del buffer actual cuando no supera `max_file_bytes` (120 KB por defecto), filetype, ubicación del cursor y diagnósticos de Neovim LSP. Si el archivo supera ese límite, envía una ventana de `max_context_lines` líneas centrada en el cursor. Añade archivos extra:

```vim
:GPTCopilotAddFile ia/rules.md
:GPTCopilotAddFile src/db/schema.sql
:GPTCopilotClearFiles
```

El contexto adicional se adjunta en cada petición hasta que se limpie. Cada archivo adicional se limita por `max_file_bytes`.

## Integración con LSP / nvim-cmp

El plugin no reemplaza un servidor LSP: coexiste con los clientes LSP de Neovim, incorpora diagnósticos al contexto y dibuja sugerencias inline. Si usas `nvim-cmp`, registra la fuente opcional con `:GPTCopilotCmpRegister` y añádela a `sources` junto a `nvim_lsp`:

```lua
vim.cmd("GPTCopilotCmpRegister")
require("cmp").setup({ sources = { { name = "gptcopilot" }, { name = "nvim_lsp" }, { name = "buffer" } } })
```

No necesita nvim-cmp para ghost text.

## Comandos

- `:GPTCopilot` petición manual.
- `:GPTCopilotAsk texto` petición con instrucción libre.
- `:GPTCopilotProvider nombre` seleccionar proveedor.
- `:GPTCopilotModel [id]` consultar/cambiar modelo.
- `:GPTCopilotAddProvider {...}` añadir proveedor OpenAI-compatible.
- `:GPTCopilotAddFile ruta` / `:GPTCopilotClearFiles` administrar contexto extra.
- `:GPTCopilotHide` ocultar sugerencia.
- `:GPTCopilotClearCache` borrar caché.
- `:GPTCopilotCmpRegister` registrar fuente nvim-cmp opcional.

## Configuración

```lua
require("gptcopilot").setup({
  provider = "openai",
  model = "gpt-6.2-astra",
  request_timeout = 90,
  max_context_lines = 160,
  max_file_bytes = 120000,
  completion = {
    enabled = true,
    auto_trigger = true,
    debounce_ms = 3000,
    comment_prompts = true,
    max_output_tokens = 500,
  },
  context = { include_diagnostics = true, extra_files = {} },
  cache = { enabled = true, max_entries = 100, persist = true },
  providers = {
    openai = { protocol = "openai", base_url = "https://api.openai.com/v1", api_key_env = "OPENAI_API_KEY", model = "gpt-6.2-astra" },
    gemini = { protocol = "gemini", base_url = "https://generativelanguage.googleapis.com/v1beta", api_key_env = "GEMINI_API_KEY", model = "gemini-2.5-flash" },
    deepseek = { protocol = "openai", base_url = "https://api.deepseek.com", api_key_env = "DEEPSEEK_API_KEY", model = "deepseek-v4-pro" },
  },
})
```

## Caché

La clave de caché es SHA-256 de proveedor + modelo + prompt + contexto completo. Por tanto, una misma instrucción con otro archivo, diagnósticos, archivos extra o modelo genera otra clave. Caché persistente local en `stdpath('cache')/gptcopilot-cache.json`; se limita por `max_entries`. No guarda claves API.

## Seguridad y costes

El contexto se envía al proveedor seleccionado. Revisa los archivos incluidos antes de usarlo con repositorios privados. Las claves se leen desde variables de entorno y se pasan a `curl` mediante un archivo temporal con permisos restrictivos, no como argumentos visibles del proceso. La caché evita llamadas idénticas, pero cambiar el contexto genera una petición nueva. El autotrigger puede consumir cuota; desactívalo con `completion.auto_trigger=false` si no lo deseas.

## Limitaciones conocidas de esta entrega

- Las peticiones se procesan sin streaming; la sugerencia aparece cuando termina la respuesta.
- El extractor de comentarios es heurístico y reconoce los prefijos comunes indicados; los lenguajes con sintaxis especial pueden requerir reglas adicionales.
- La integración nvim-cmp es opcional; el ghost text funciona de forma independiente. No se implementa un servidor LSP propio.
- Los nombres de modelos son valores iniciales, no una garantía de disponibilidad. Sustitúyelos por modelos habilitados en tu cuenta.
- Neovim/Termux no forman una única matriz de versiones; se debe ejecutar la prueba funcional en el dispositivo objetivo.
