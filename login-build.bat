@echo off
REM Script para login no GitHub Container Registry e build do projeto Flutter

set /p TOKEN=Digite seu Personal Access Token do GitHub: 
set USERNAME=SEU_USUARIO_GITHUB

echo %TOKEN% | docker login ghcr.io -u %USERNAME% --password-stdin

docker build -t auditoria-eleitoral .
docker run -it auditoria-eleitoral
