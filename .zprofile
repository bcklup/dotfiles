eval "$(/opt/homebrew/bin/brew shellenv)"

export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$HOME/.nvm/versions/node/v16.17.1/bin/node
export PATH=$PATH:$HOME/.nvm/versions/node/v20.9.0/bin/node

ssh-add -K ~/.ssh/id_ed25519-mfp &> /dev/null
ssh-add -K ~/.ssh/id_ed25519-personal &> /dev/null
ssh-add -K ~/.ssh/id_ed25519-wblue &> /dev/null 
ssh-add -K ~/.ssh/id_ed25519-fs &> /dev/null 

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi
