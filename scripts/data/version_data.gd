class_name VersionData
extends RefCounted
## Metadados de versão, autoria, links do repositório e histórico de atualizações da Fazendinha 2D.

const CURRENT_VERSION := "v1.3.0"
const REPO_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-"
const RELEASES_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases"
const ISSUES_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues?q=is%3Aissue"
const CHANGELOG_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/blob/main/CHANGELOG.md"
const AUTHOR := "@marlonferreira1800-hue (Marlon Ferreira)"

const HISTORY: Array[Dictionary] = [
	{
		"version": "v1.3.0",
		"title": "Novos Cultivos, Upgrades, Clima, Música, Animais & Mobile",
		"date": "2026-11-19",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.3.0",
		"before": "Apenas 3 cultivos, ferramentas sem evolução, clima estático, sem música de fundo, 2 tipos de animais e sem controles touch ou botão de reinício.",
		"after": "6 cultivos, upgrades de ferramentas/energia e Aspersor 3x3, chuva automática, música cozy procedural, Ovelha e Porco, Menu/Reiniciar, controles touch e Auto-Farmer 12 canteiros.",
		"highlights": [
			"Antes -> Depois: Fazenda básica manual -> 6 cultivos, upgrades 3x3, Aspersor, Chuva, BGM procedural, Ovelha/Porco e Touch",
			"Issue #7: Novos cultivos (Milho, Tomate, Abóbora) com spritesheets e ícones integrados",
			"Upgrades de Enxada, Regador e Resistência (Nv. 1-3) + Aspersor automático 3x3 na Loja com abas",
			"Sistema de Clima (Sol/Chuva com previsão e rega automática) + música procedural em loop",
			"Ovelha (Lã $60) e Porco (Trufa $80), D-Pad touch mobile, Menu/Reiniciar save e Auto-Farmer expandido",
		],
	},
	{
		"version": "v1.2.0",
		"title": "Modo Fazendeiro Automático, Painel de Atualizações & Deploy Web",
		"date": "2026-11-15",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.2.0",
		"before": "Controle 100% manual sem exibição de versão/histórico no jogo e sem deploy Web contínuo.",
		"after": "Modo Fazendeiro Automático (tecla P), Painel de Atualizações in-game (tecla V) com Antes vs. Depois e deploy automático no GitHub Pages.",
		"highlights": [
			"Antes -> Depois: Jogo apenas manual e sem histórico in-game -> Demo IA ao vivo (P), Painel de Versões (V) e GitHub Pages automático",
			"Issue #3: Modo Fazendeiro Automático (Auto / tecla P) com rota inteligente pelos portões",
			"Issue #4: Painel de Atualizações (tecla V) in-game com histórico de versões, autor e links para Releases/Issues",
			"Publicação automática no GitHub Pages via GitHub Actions",
		],
	},
	{
		"version": "v1.1.0",
		"title": "Correção de Contraste da HUD, Áudio Procedural, Save/Load & Animais",
		"date": "2026-11-15",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.1.0",
		"before": "Texto da HUD sem contorno escuro (baixo contraste), jogo mudo, sem salvamento e animais apenas decorativos.",
		"after": "HUD com contorno e barra escura legível, AudioManager SFX procedural, Save/Load JSON e coleta diária de Ovo/Leite.",
		"highlights": [
			"Antes -> Depois: HUD com baixo contraste, sem áudio/save e animais passivos -> Contraste corrigido, SFX procedural, Save/Load e Ovo/Leite",
			"Issue #1 (Bugfix): Contraste de leitura corrigido nas barras de Energia/Água, hotbar e barra inferior",
			"Issue #2: Efeitos sonoros procedurais (AudioManager), Save/Load (user://savegame.json) e coleta de Ovo ($30) e Leite ($45)",
			"Importador CLI tools/import_pack.py e expansão de ui_icons.png (128x16) com itens CC0",
		],
	},
	{
		"version": "v1.0.0",
		"title": "Lançamento Inicial — Protótipo Jogável Fazendinha 2D",
		"date": "2026-11-15",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.0.0",
		"before": "Repositório inicial vazio sem cena jogável, lógica de fazenda ou spritesheets 16x16.",
		"after": "Protótipo jogável completo em Godot 4.7.2 com cultivos, loja, caixa de venda, ciclo dia/noite e spritesheets CC0.",
		"highlights": [
			"Antes -> Depois: Projeto do zero -> Fazendinha 2D jogável em Godot 4.7.2 (cultivos, loja, ciclo dia/noite e sprites 16x16)",
			"Mapa 40x24 em TileMapLayer (Godot 4.7.2) com ciclo dia/noite, poço, lago e casinha",
			"Cultivos de Trigo, Cenoura e Morango em 5 estágios com loja e caixa de venda",
			"Spritesheets 16x16 pixel art cozy e catálogo ASSETS_GRATUITOS.md",
		],
	},
]


static func get_current_version() -> String:
	return CURRENT_VERSION


static func get_history() -> Array[Dictionary]:
	return HISTORY
