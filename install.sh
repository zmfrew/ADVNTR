echo "------------------------------------"
echo "Cloning Repo"
echo "------------------------------------"
mkdir ~/.bossman
cd ~/.bossman
git clone https://github.com/Camji55/bossman.git
echo "------------------------------------"
echo "Installing..."
echo "------------------------------------"
mv bossman/Source/bossman /usr/local/bin/bossman
rm -rf ~/.bossman
echo "Installed!"
echo "------------------------------------"