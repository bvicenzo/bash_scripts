Bash Scripts
============

Meus scripts mais usados em instalações, configurações, e etc

Instalar o git para clonar este repo, copiar os dotfiles para o home, e executar os scripts de instalação

```sudo apt-get install git git-svn gitk ssh libssh-dev gitk tig```

Clonar o repo, entrar na seguinte pasta instalacoes e rodar o seguinte comando.

./instalar_tudo.sh

colocar este fonte no **~/.bashrc** logo acima da parte que carrega o arquivo **~/.bash_aliases**

```
if [ -f ~/.bash_environment ]; then
  . ~/.bash_environment
fi
```

## Programas instalados
  * Imagemagick
  * Java
  * Memcache
  * Mongodb
  * MySQL
  * Redis
  * RVM
  * Skype
  * Vim (Com o Chickivim)
  * VPN (com jVPN)
