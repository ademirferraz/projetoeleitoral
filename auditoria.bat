@echo off
title Auditoria Flutter

echo =========================
echo LIMPEZA
echo =========================
flutter clean

echo =========================
echo DEPENDENCIAS
echo =========================
flutter pub get

echo =========================
echo ANALISE
echo =========================
flutter analyze

echo =========================
echo BUILD APK
echo =========================
flutter build apk --release

echo =========================
echo BUILD AAB
echo =========================
flutter build appbundle --release

echo.
echo =========================
echo AUDITORIA FINALIZADA
echo =========================
echo.

cmd /k