setup_config() {
mkdir -p ~/.config/noctalia

cat > ~/.config/noctalia/config.json <<EOF
{
 "theme": "dark",
 "blur": true,
 "animations": true
}
EOF
}
