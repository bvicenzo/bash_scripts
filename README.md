# Bash Scripts

Meus dotfiles, aliases e funções de shell do dia a dia: git, rspec, tmux, atalhos de busca
e utilitários para projetos Ruby/Rails. Funciona em **Linux** (testado no Arch com
[Omarchy](https://omarchy.org)) e em **macOS**, com **bash** ou **zsh**.

## Instalação

```bash
git clone git@github.com:bvicenzo/bash_scripts.git ~/.config/bash_scripts
~/.config/bash_scripts/install.sh
```

O repositório pode ser clonado em qualquer lugar: todos os caminhos são resolvidos a partir
do próprio arquivo. `~/.config/bash_scripts` é a sugestão por seguir o padrão
[XDG](https://specifications.freedesktop.org/basedir-spec/latest/), o mesmo onde git, tmux,
mise e companhia guardam suas configurações.

### O que o `install.sh` faz

O instalador é **interativo** e pode ser executado quantas vezes quiser: o que já está no
lugar é ignorado, e nada que já existe é substituído sem perguntar. Antes de qualquer
substituição é feito um backup (`arquivo.backup-AAAAMMDDHHMMSS`).

1. **Dotfiles**: cria links simbólicos nos locais XDG.

   | Arquivo do repositório      | Destino                          | Observação                       |
   | --------------------------- | -------------------------------- | -------------------------------- |
   | `dotfiles/gitignore_global` | `~/.config/git/ignore`           | local padrão do git              |
   | `dotfiles/rspec`            | `~/.config/rspec/options`        | local XDG lido pelo RSpec        |
   | `dotfiles/tmux.conf`        | `~/.config/tmux/tmux.conf`       | só se o tmux estiver instalado   |
   | `dotfiles/tmate.conf`       | `~/.tmate.conf`                  | só se o tmate estiver instalado  |
   | `dotfiles/terminator/config`| `~/.config/terminator/config`    | só se o terminator estiver instalado |

   Quando o destino já existe, ele pergunta se você quer **manter**, **substituir** pelo link
   ou **ver o diff** antes de decidir. Também oferece mover para backup os locais antigos
   (`~/.tmux.conf`, `~/.rspec`, `~/.gitignore_global`), que deixaram de ser usados ou
   teriam prioridade sobre os novos.

2. **Git**: em vez de substituir a configuração da máquina, adiciona um `[include]` de
   `dotfiles/gitconfig` no topo da config global (`~/.gitconfig` ou `~/.config/git/config`).
   Por estar no topo, as configurações da própria máquina continuam tendo prioridade.
   Nome e e-mail ficam fora do repositório; se não estiverem definidos, o instalador pergunta.

3. **Shell**: adiciona ao `~/.bashrc` e/ou `~/.zshrc` a linha que carrega `dotfiles/profile`.
   No Omarchy ela fica no fim do `~/.bashrc`, depois dos padrões do sistema, então seus
   aliases e funções têm prioridade.

## Estrutura

```
install.sh                  instalador interativo
dotfiles/
  profile                   ponto de entrada: detecta o shell e carrega o resto
  bash_environment          variáveis e prompt do bash
  zsh_environment           variáveis do zsh (rvm, nvm, fzf)
  profile_aliases           aliases
  profile_functions         funções
  gitconfig                 aliases e preferências do git (incluído pela config global)
  gitignore_global          ignores globais do git
  rspec                     opções padrão do RSpec
  tmux.conf / tmate.conf    configuração do tmux e do tmate
  terminator/config         configuração do Terminator
oh-my-zsh/themes/           tema chiqui-ruby para o oh-my-zsh
```

### Configurações por empresa

Aliases, funções e variáveis que não devem ir para o repositório podem ficar em
`~/.company_profile_environment`, `~/.company_profile_functions` e
`~/.company_profile_aliases`. O `profile` carrega esses arquivos quando eles existem.

## Aliases e funções

### Busca (ripgrep)

| Comando        | O que faz                                                                    |
| -------------- | ---------------------------------------------------------------------------- |
| `sgrep <termo>`| busca no projeto ignorando cassettes, fixtures, logs, `tmp/`, `vendor/`, `node_modules/`... |
| `rbf <termo>`  | busca só em arquivos `.rb`, `.erb` e `.arb`                                   |
| `jsof <termo>` | busca só em arquivos `.js`                                                    |
| `jsf <termo>`  | busca em `.js`, `.json` e `.jbuilder`                                         |
| `replace <de> <para>` | substitui um texto em todos os arquivos do projeto que o contêm        |

### Git

| Comando                  | O que faz                                                            |
| ------------------------ | -------------------------------------------------------------------- |
| `clear_untracked_branchs`| apaga as branches locais cujo par no `origin` já foi removido        |
| `update_my_branches`     | faz `pull` em todas as branches locais                               |
| `update_repos`           | roda `clear_untracked_branchs` em cada repositório do diretório atual|
| `update_git_submodules`  | atualiza os submódulos a partir do `master`                          |

Aliases do git (em `dotfiles/gitconfig`): `br`, `cm`, `co`, `st`, `pl`, `ps`, `plr`, `df`,
`dfc`, `dfw`, `mg` e `clsorig` (`remote update origin --prune`).

### Ruby / Rails

| Comando                    | O que faz                                                        |
| -------------------------- | ---------------------------------------------------------------- |
| `all_tests`                | `bundle`, prepara o banco de testes e roda o RSpec (inclusive engines) |
| `prepare_database_to_tests`| roda `rake db:test:prepare` quando a task existe                 |
| `clear_logs_and_tmps`      | limpa `log/` e `tmp/` de cada app Rails do diretório atual       |
| `update_bundler`           | atualiza RubyGems e Bundler em todas as versões do RVM           |

### Outros

| Comando            | O que faz                                              |
| ------------------ | ------------------------------------------------------ |
| `fo`               | escolhe um arquivo com o fzf e abre no nvim (ou vim)   |
| `hc`               | limpa o terminal, inclusive o histórico de rolagem     |
| `ccat <arquivo>`   | mostra um arquivo com syntax highlight (bat)           |
| `json_indent`      | formata um JSON (arquivo ou string)                    |
| `json_view`        | formata e colore um JSON                               |
| `load_venv`        | ativa o `venv/` do Python no diretório atual           |
| `start_containers` | inicia os containers Docker de uso comum               |

## Migrando da instalação antiga (`~/bash_scripts`)

Antes, o repositório ficava obrigatoriamente em `~/bash_scripts`, com links em `~/.gitconfig`,
`~/.rspec`, `~/.tmux.conf` etc., recriados a cada shell aberto. Para migrar:

1. Clone o repositório no novo local e rode o `install.sh`. Ele detecta os links antigos e
   oferece mover cada um para backup, inclusive o `~/.gitconfig`: como agora ele é
   específico da máquina, o instalador pergunta seu nome e e-mail.
2. Remova do `~/.bashrc`/`~/.zshrc` a linha antiga que carrega
   `~/bash_scripts/dotfiles/profile` (o instalador mostra onde ela está).
3. Apague o `~/bash_scripts` antigo.
