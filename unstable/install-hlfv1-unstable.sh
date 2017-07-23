ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��sY �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�l������>a�X�� �ڿ\ۑ- �8��W����F�-[5�]��mS����@{�� �y��E��tGVuh��r�sI�ړ�(�34���fZ�Q~���iX��U	@l�0;�.��6I�z_��ug��*K�|�*3��.��� ��� t�dWsR��C�A�:����Az��%7,U��P�Qm��JN�<<7���d+�j�&0��� �)�l��-� D��>;�݅ú�U�"X��у����c�X��FR�5{Nj��*�2�L�a5���e���3#AJ����i[�������B��4����g�^M�|��E��h�H�����fp{��Kc̒�f��YE�3���w�D�+r�@5L������9e��{5C�	We��B۩����u0s�eR�#�X���sFݔ{5)q�\I�ub��1*�������Zy�A~��f���_:t��%Z�W"���tYi�I�w��R�Z���5a?��?b�ȃ���x\�i��0Z����?�
h���9����s�߁��4��@���}� �/�<�,���g�1^@��?�����[<�.�P�HC�;�m����P��OS���C�?&���Y�T+��ẇ+�����s�D�"g�!��1�oZ~y0G����������6�����s�ߔ�.�·�mC�6�������"�@�?�C* ��>�Y��x�5޿�2�bѾ��0a&,x�Ӿ����f� xd0����c@֛��Z���]}�&v� ��v��Zx��`Zj_v0���B�$�Nǰ��*��*P�I�D��⼌.��^�z�M'5C�*���$]14w��{�~GM��m���DdWK{�����W՚!�R:j���mW3A(��`{|�	H��q]hҳ� �\�_��Dx��'�����e�a~�E����9���QT"L�1W��Fi�p��OԴ4�:p_p������c�l,Ơt�	�F�����`+�\�8Łӑ�U5�(k��>D�X���z����M�َa�xI}��Cv���&a!`� ��KJm�wؚ<d����i��5�RG�*��=\����m��{�gA�]M�.;�B'��j��qn�q9�:wc�e��Q��4k� ��Z��+<��� �Q#_Il �` Q��PȘ^�c�09n�	���F��)�U�A�0�'�cL��p�9�y�:摔�}I��� �8�е!�������I�`&�v��9�_]Uw�)�io���頁�p��Jt�>ԠlC`C*tT�bـ�My?���9���6��Q� �9��_R~EC�:�6��w����kD��E7��������$��������׈S-���y=[���������Ж�i�p���0g�ǌ�`�����������l�#��s�@m,�������n����NJ_�_<���l����iS�c����v�����4ײpHk �ǰ�T:W޻�:�����Y%U�V���t�1��|ˮ���� _mc����DVnFL�s���T��J�WW�f�o�N  ��nC�Gd��n7�E� ��&��:�lxs��F��~>����;�Yz+U�\=��
R�V���	�y��xaC4YM��L&Jﱂ�lZpo���P�ë�$*�x�<������s��xKB��I�Ed��@w{h������,,.��dAG�t�V�d���舯�|g]��f�BOr��,bs���v���ȸ��+��l�������a��O���� .��(�L�q!���u���?��V�3��UG�i 2-�R/�hG�	�W��ֹ7̑�){��m��gb�M��:`����݃����m������Â�\���pQA���S�%�7t��l@�2��i�����d�i�)�������@��J�uȗ=R��WI��9��v`�!DWs�<#��g,D&3��F�1js�2� L�	2EFM�6ЍP4(�(k�%S/T���0�}�����\�W�Sh��!��<�5F�U�� �_,���r�'n���//�w^(�̬�G7�k��U��#ǈ�C׏6pdOb5� �	p��h/�`�g��K���Q�C�;��b�l���M-]�vL�ڻo����^���S���7�_�G��GP�K5�э+`X^�˒�.H�^s�6��3�0����F��Ϟ��$`:�9o�C���%,/�w�,�(�#:c�,�������{���sE�y�����T��l2W$�Rd���J���_��Cs�r'p���N��������K84C���a;��F�!����[=���-����2�?�
�խw���P�1<�U��z'Ƣ��p����.f�(���(4�� ���2��ud4 ���n�9�#d�[���/(^�a�ϴ��l�?��	���8���u������/��s����x��^!��5QW�ޥax��&
̹�-H��T��멳�x&������K�=|� �o2���5�<�r��v �%�2���.�%r{�!�*���CI*���tY�T�Z����R�J����'��R�X�su�i�H_�"���r�џ`�|)���gy�.���R���i8��C#2�|x�;���b��3�'e.vu5�|e�����sՓ�I��\��Qo���l�KSX�e��W���J��5U���zw<��6f@�B
ض5M ��U�n4�w.�r����3o�v�%~j�}@X��wװ���>6�������Z�����������N׼�.\��%��9��� l��fv�n5S�6Y���6�K�i|���b�o�X,z�b���|�w�y������Z2�����{翉�o�?����\
���ð���G���������]�?HC~x�����Ea��ȷ������WRϖt��������U5
6b'n	@���SW`����-p�Ss�>,���s)�B��������<������|����`/�(���7`-*�ȫ�+P�T¿(}�VW�4�e�4����}.�X$���_N����~���$�T��v��1�pty��6�Ηa�����P����fr��ǹ������?���Fx��d��a�a�y��Az�&~C�u)J1�h����ЃG1x;ȕ�|�^�0~xf�[0�S�q�?���⿺2���t��|d��*W���GT����l��(�q�9o�L�R�	v�.�����a��3>$Ï�x�p��	�������H�ݡ����l�6��u�����<�v.��(�[��?A�n�YP��5uF}���o�������?��Z~�F���\b���
�'�V��+;�D��Hp<�!�B>�'�(��|BH$�F|G�;���_Q��5]�Vz�ߨ?�����~A���ӭ?Q����'�>����ۆ�no�_����-b�����W[���t��j�"�[���0{�/[���?lQ���k���cKu�o�y�)���q�+C|�D �O���a9"?�,���?�pWjcu�e6�=p��?ǷL�?7;�������G�x`�G��P�(m�Ӡ-�<���L~���?�����r���5,Y��?��Tz�#m�m�ˑ��3D(,��r���X��(�(���I���7v��Ea�b;M�Q[(2��6.�	�G��Pǵ}��Tm��;!I)�+��T��2��X�H�{��˥�穔���� �۹�XtKz��j،$�C�m\5��v4H�Or�i���@�����ٚ��R�z�B���v�������N#���7�|,]d�Ś��T�u��&��u��qO8��۹�Vŷ�Q�����䞾�to��iE8op��~Z�=�BU⊝�z�7s��Q���2(��B5ǔ�9����4f��^?>O6
G� ut��e���z�R����ޥ���#.c�ǧ}�'�'U鸐<�z~Q(��k\��I�Óc�\~[<o\J�B�!�`p|t\v�cADc�*��G�^h�^�ߨ&O�H&����l��'Ķ�M���i_drb2��\$��l��R-ԍ|?^|���N,���\}������z\+�Z'�x���U
����9H�+�]h�c��4̶��j2_y4��fz %#�#<����X�c�_.$�֎$��b!e�^5s��n!u �=�Tv��\2�^��������C��K%�Ieb�{#�#.w�1����ȴłTK�R�}p{�������	�w�˄p��t��W�tN���6�'��f��kW����+�6��!���q��^[/�ʌ:L�x�Y��Ž�:ay���#���U8���7�v^�+�5���Z?��a���ƶ ò1&����	��0�����F���}uw�������5����t��O�e���ϵ@�N:,��hq �	I}Jr�}�&�����,3��ut�f�� �Oj$�v���iI�3�-,f�5��e�P�,��A&WJ�V?eՊe�P�^f�T��e��4�U��R|�[����ѠP��sY����5�p�%r�"F�5w�O�W؃�B�(��R�o�c�z�?�<�~v�6��:����n�Sw}O>��������k���_K�s������ɾ��H�GcWHZ<R�GmQ��Kʤkr5�pq�v#6ߴM��}J��i�Е��Oߺ�L9�1Ѩ���A�{��NOl�VLb���՜��{{�|��O=j����M���%-��K\�@�cq~����o���@�0����%�_����2N�A�h��g8�0�6���Wy�ܖ
�]0zh9� <�z8@��%/�d�m�@�T]%SFGuɺzI�6�ɺ�����QK�̷��$�����r\���#�E�w- �6z���@|I�q�tń
��
� v��P3$	�:$j)�)B`߰���;�ȣ�.���k��G�<���Ge^R�5�N�>6�>Z�5��8Z�C^��$u��A�n.��:HD�,�#q8+����-ԮE�*@�wm8?���&ƕ#�'�(��D~��°
�D��������>)����?��9����v��n�����zR��.���"N\�pB $pA �vBHh9�u\����m���ͼyp��̳���������U�v<�`����I��@�K���F���7�#L&`�
D��^�DSLț�>`��@e��$�l���B�]}�xC�H�q]9�jpz��X���(D�9i������:� �'ef����MП� �d����}	0�h2>��g������a�������;�:��5�]����w��?~ 9#���+��wKh�,�v�)l`obqeP�}�h�%��
�e~NNs��L��6��v��{�Ӵ��)��܃)�`~��{�FS�:���^�~Q��d����2�EH�fk�$0�$}y������/0�3����uB!��5%xk�?=���`���/\�x�_.j�n�W(P���+�O֘����7���:��J/Q-��Q�'$�LO>w6��9���#Y����!O\vn3}՟�އ�"�dM�]��T���O�T�l@��m#ޒ�C$t��pjM�@�Q��Sj�^;��R2����5��M�t��EE���a�,)k�lh�!S@vQ����Õ������=�q�ƑN�:76:ڍ�~H&����@�Vŗ9=�򨛞?��0�?uj��n�����@\�ȷ���E�L�zc �X�N����{�n�F]3��=�WUF�C��~݉XW���x,�ؘ�'����?����KN����?��?��|��?���|���/��������)�)�7)bA����￾���_`���hG6>�B�?�"�%2rTR⽸�$b�H<�z�d/I�㽘L%� II���H�3rfH(=%.��nh7��O�z���~�|�����������L���+3�[���ЯGB����
Yk�����?����a���p��{����o��_=�˃�?=X=����mG�0VC�1e��jlQ����澥3%a�5m���U=��*�Z��Ϙ%X�EXy�*" ��L���jہU\W`�5�v���	i%gG��%��sᬖ�: �-����Fa�]�E��i�X��9M�9{̶[�qg�YHC�/��v���
�M��	q�>*��ay܍�gB}`�lLp�����4<��[�-��v4c	u�Ϋ��%�y���Hl'��Z51�A��f��``��ˣ�ʥ�~�6�N²����<��V��7ٱn�E�*�Z�^�HD�˕g�ܞ)�z3		}P�	��͢j�#U�V34�{5?�4��|��'��A۬��E��i�}���uV�s�ZS����S&��7�sp>$:ń�7��Y�?1��h����0E�Y�i^�.&ga�yf1m���E�3i=���J��d_ǳ��e�ˣ�T�����L$���hZu:?Jӳ��+sk09�Ǌ����>6����u���k��.�K��K��K��K��K��K��K⮸K⮰K⮨K⮠Kb��
�`�%�l�h�-�7�,��ZEi�����n����T=Ü-�d�܉���hq��D�O��j΅���/	�{��z�(ڷv=�=�s=i�  ���杈T���!<�s��-���(Rϧ��؜���;T9fi�NKlv��,��V!:�%9jF��"����'�&�w�.g�'*j�m�������ϋ��TǠ{�Y:� "��ʳ�I%j��B�gK��d>i���s�R�S��x�BS.�I*�0�Pv�d����[jF[$bV1M%Y�>)��������+G�Z��iV&�*!Gz,�z��p�N�+�l�ݛ�Y���v�v^=
�ނ�������h7��sx��n�#��-�Y���ì�.���p~X5t��}zg����Kv_ل]N�=���_�Ph�������
\�-��G��8)��B?�&x���o���>�����<����%�ٵ�����L+��[�YE45�ʴe.U?Iʽ��ė��s,��|~6���];���H��"n5�yz���M��\�c�j6���˶6-���4=\A�7�(Di��Ȩ]�Y���qc#Hf-�Y�B�YR�Bj��&��츪��jD&Y��fGrfH�+�/���0R�hG�n��%�k��5��i3�k-O�������A�m�D�+��Ic��2h{I��i3j�C�i���F��1-��,2��4&� �[5�������������9�@���5�~��ۃ%}D�9J�\�Y��5Z;Q��I^��~s8<�"�r��N*0�P#	)\3����%`�
REG�ۣ�}f��㺲ߙ�J-��wyAo�'>�\��ڵJ�E���ʵv1���aM��J\�T1�i������/��7���i3@�-�c/@f���	_���	+r1�m/�gܢ�e݀i����i��W�ԝ���{�N���n�Ճ�_n ��i-3N���bly&[���U��
�j�m�MqZ>Ѩ��K��AK�5�Jk��q����cׇ�'W�5�J��Z�l��d�}^.��Ņ+�@�N��9�rV�i��Q�3&[�y�V[ù�0�Z5Ϋ��|���~��??�s:��Q�y���|Q���a���iL��'骒�+�Bk 6�1Wl�fE���x{�;W���"T���|!�dϥ�^w��-���S�b��D�l-a���ڳ����Z�(�ȑ,V�D(φ���DKM*Ô�>�	�[b_�#1�<�:�y΋u�K0B��΄����L�U|�3p:�9�:
�=�B��;�Fq�5��G���U��&��֐�L�|d0�&�kEӳN���Qn�/�)�әF�N0V�*'�f�8��c�2=�iDzٟ �r[�Bxe�CI5Km�<����GK(T��5�8j��3%:�b �BAܰ��Ca����H3�/&j�|J%���铓̼JφD\�&�h��&�5À��vd
��-0ɹU[F:\������2�
�W����Kc���q�#���wC�C�`&/��y��l�8�D�� ���3�B��$ވ���/�X����Ds^��v|�_!~-�*#sj���z?��i�O�G�<.��-�����;��_~�%��_�~�V�z�q�C��Σ��"4�,>�<h§��x�A�L����΁�����	�~�}m�Һj@�����k2��>%~�f����s:�����y�'���Ρey���b��]�C�|����t.�Ҥs���C������֟[��Cx"k~3�/�\��/��]8�!�~���U|���\��/���'��&�_OIV��|����;��� I!|l�L�!1z�L&cV�$�`����uN��F�� ���b_v���3	�6aMsl�y;�6�M_%��w�sH~�>aT��FP	�K��X����z���׬�Y.�l����R] ����/�[*q��\�,p ����Z<���5�$�p���HPP�!��D�tFA�G1�0E��g�Bm@��	B�������!f����o�0\$��w��I�M'$�[��7��L��P����a헧������ ��z�B�al�K��p�{�'[T�c�?��;��9�4\�+�`�6>u�A�3E7����ϳ��G�p�Yd��M�+�b �V��g}�(��d���mŦɹ.d���4��m�/dm���V��ڦ����|5P3<4��
���{H�0�\��E�$��@�au�����d݀�[&�U������D�����1�~�lJ}a{sѻ7o�P�h����`��~|���]������4A�_q�H&�iⳞU�E�c��#��C��.6��Q�#Ѻ��n���7޼Āc�-4Ren�qsć�����S5��I|�ˊ|���t��qq�x#���\�'a|<2��͘`f�Ö�ݒ5Qt�l]\��m�H�7��w��L����U!�����}�Q��z4�ٌs:@�=�谇1�{� v�ᔀH����v�:��f�^u�2鮕8�C���F&�z��CI�j�P@J(/�\p9$��:w�J�⬑51ts|=�U�7JanX3���b�y�y0''o3;sm8n+ �+�!l
��j�����<r$X-A9O�oG�2
ّ��~�\	Q����[M ���D:l����b+�KvΤI�	֮��/��e�zc��K�I{�0���c�-�83���wK�Ht8P����1Y���m%��+�$�(y�J���a�dfb�{��5�kLCJ�<�����eo�+"w���$_=D�C#��zl╵a��h
ݦs@f"���R7繡�WE�_t��,�c4ewBii�'"(���1Xwmqpc��b��d�ڍ�H���7�c�����|5� 8C$?�6#���������^x���8זq���D*�Z���:���>���|P�c��4�)A�!�u��d˝������4D��6Z�h��gO��)��YX�����A�%c��su��LC[jK||U.��,ǗnP�jں��):q�`�\S��~�r@4*�^,��� H�T&��DL�%z�d��Uz���Q D��?�����$A<�V@4	Ńcɐ��n�CW�8���4�2��ɧ]����8!/�����KCn܊-���9P/ƒ� )� �$E��HJ2U���  ��xFIE�ɴ��� 1(�tF��
$�C>����߱M>�?�Ҙ��m��u~��s�o���[�N��r�F1$�61ؚ�5*����K��Rg�:�y�����i��/q�\陬HS�r2�!re�e�\��,��ȥ����8�Pa����kH�뗷vɖ�+��KB�ʳ�d�Q���.Tah���.���X ��d�2Z�	c+�he-lN�aU��S	�������[4M��㖑������.�yE��D$���nJ��}�d���b9��1��K|�R��(����i���#?�h����+JG)X�i��I��S��V+|Y|6i��p8��Z�g`�LGnxu`(Ή
?�C��� ��n���.m֍�d�`�B�!f+��?-sb�R?`�yztܷ�^��8k��`�ýJ���J�*�k˪86�6DZ䜿,-����e�m�,s}���X�m���ٻ�洵f��_qߩ{�<ܪ����@1��&�<I ��_�vCbǎ�v�^)!&hKk��ݽ��=S�$���O��/;���}�z׶����y����_��ȱ�ܱ=�_n�����z�����-߿��?������{�2��+׿���(^��(������lۗ�{�%.l�tw�߯��s��;��Β_n��w�>Ҕ�N��χ�]�Qy_�E�^�ۯ�����90� ��_hR�x�q�E��x���>�w>�����'I��?
����!跬?C�4�?
`���Q���$����?��<���  ����4�?���4E>����?���*�������/ç*����/���-���;���π��o��)���%`���;�@�!*�G��G1)�#A��3w�#���%A�IqĄ'0���q@F1��~�o�Qw���?�S���!�7�����_���J��2�,Ws���m�R�;ڔk��QFR޵��0�ۇ�^���ƕ�Y���a�׆{n�21���au��F_t'Sj8�;T����!����SN�I���kj�!�x?�'Ku�.ϵ����v��?�������CaH��p(��-�R��?
���4y'�� �� *��Aa`�_�����x����q� �����L��K���_8�S�m��?`���N�K!d�����p���[���Q /�����D������������	`N'��9�t	绀�����B�`��B��� ����X�?wS����?� ������(��Q��߾����K��VZcQtKټ.�b.���r��y*��34��S�g���I�����a��7�~^Z?���~�y�a,�F臷�}>�}3�������YZ2N��QYD�͸�,���eyw3\��Yc����tgr�U���Zi�S�b�j���j���o����}�Om�į�}V�l�R=�љ���� �:��W,������.g��z����S=n��;͔��'fF$qΝJ���oKɚU�(Ԇ�Fs��Fu0]���}��:ru)��u�w[�l�m븫��{�S�ےX�?8�/�k�(� ����[�a��p�_��p�B,��;�O��F��'���b��;�����t�@�Q���s�?,�������9�����	���?��������?��wtw�3y�Ӎ�=��yw�����+��>�����������㰞x�|�ݮ�k���`�?�s3����,��}�"v�&S�o-��Q�٦�IN�'I��Z������d�T�޲L=�����q},�r~����� Ք���O�΍���1>�t���c|��;�1�섮�h��Hbw?��xzk�x9�̡�U,F��U����<�[��绣Tf�'�WL��^�ȉE�z�8i�3{kh���/�B�Qw��0����f�m����s�?��yv/\����	p��hPB8�($y*�D.`E��$)�ɘ�@C1��y!�� $��9Fb2&aF�������?�N�������DY�˕���*�ۓtX/d����ڴb6IPU��mQ������>��8O��Q]�(u]%�㦷�m{.W�ŒQ�t+hI��Ms�m�}�WQ�.'\R�v�������8����Y
���9��
������?�����a`������8���og�zw��K�e?��y�/�%ޝ5�z��z�4�8]��?���-��&��D�c�ץ�U��̩<&F�3	U���,!;I�X������q�+�Ѯ�u����Ӱݷu�l��n�q��x��4����n��k�' ��/��*���_���_���Wl�4`�B�	�;KB����Ng���_���	�UUُw���<h�>����hZ���I����+�NJ����=3 ���@|�g�� 8Kհڛ�S��R%.C ^� ��ъ���\jf+�qZ-�9�#�]���F=7����q�NU=�t)�:����zT8���V=�wVo�v*Y�r1M�0'Ͼ�����W���]��z�`�%7�s<�U����'!O_10�E�r��$�ت�{���)��c� C�A�qZ�ź��T����JI�,��70��KM��2xx����P6u[5�^�llw�JY�v�S����FM�L�#�h.�?�lz�:����D��R9vV��Qexy�-Vf��g�/��A��r�8�����w���b��?�
|���P�/P��K��m���P��8�?M�9���$@����-P��/��s	�?
��?����?����DA�A@��(�x���dER����c6$}��}�g�X E^�?�.� |��#Q�Y!�|ޏ���ÀC������	~g���
v���v��b�ui��t�'���ٱ��'�2ٕ�ŏ��NG�Do��N��Ҩz�nS���C,��ZO�v�"i}l��c�'e��+�>�;��麴��oU��*�m�d��}-p��)����� �������o	�P����<MC����&�������h1�w��_4���M���9�˗���� ����;-@�^��������ok�Z���1*+��j LV�ln����B�5����ikL���������Q6����<���N��9��I��/�~Wwb��Tuvp�fo���`2l��\�kc���֕ڲ9���y���ܨ��3�p��	�:�D��Ԍ��c�c5��nWi�2[%.g�ڃ��emk���rne������Dl;�Y�Xl�'��ڒj�7't��������NdSwU�Vٴa�'��;�Y�?I\_*��^I�.v�}7�I{5*'F�p~����hUY�k_7rSv1虵�ON�*+	��r;2�e�Ȁ��;�=��[��?��+ �����?/;���������N�7O��@�7�C�7���?迏��<� ����s�?����r���Y \�E����� �G���_����b�������P����]z��EO�}�X������H���$y�3��(�����öP4��������]
�0�(������?u���?`��`Q ����������@���!P�����H ��� �t	ǻ����n�P���?�)�n���s7������C[H�!����������?���?��?迂��C��?��Â����0���`�X��w��@� �� ��b��;��� ��N(�/
�n���?���?�G������������C�?����!��������?
�
`��f�1�V��� ����8�?��^����S�Yd,����!ő(ţ��Pbi&f(�#��<��(�R@	�/�,�	��u��������� |��;F��OC>����9��*U2�/��NH�țM������,�	�%�H��V�?���-O����w�l�������v���tg���
�S�]��U)����ܣ��\esn�FW'�:�/��j�m�1�rYswǦV��"V���T��v7_���p�����8��gs8�-8���,��
��������/�'��_q���_;dL�P�ZݼRZ6�DVj�b�6mG�N��/+T��嵾��n<˜�3�Ne�U����؈&�f�c��vk�H�u���;�)��S=���CU޴7��n1���$�0v�f9m�u΂���c�����_D�`�����xm��P��_����������?������,X���~/������k]���_��R_���n��3���^T����J���߃��H;M��J���}H���Y7��l��%m?�6<�Ԇ� !kKDZ��O�Z�����ͤϓ���7�NҘ�S�tʤ͈I-�8i&��=��V׷R��ʉ[m�O�����t���v+Jn*�{a�$zE9���l/6�h_����[�}O��:e�z���!��5h1N+�X���6���۪Q���4s|��`0���_���šy�F�n'��͙א'��D����ʠ�d6�J�$ӫd]p�x�af��r�	�?o��;������-��g����&���O
4��"�G���߯\�o�
�p��(���'�#�G?�WG7(��(�����%)�p���n�Y�@������P��O�?����3���C���VWU�����ô�{�L��IIJ3��ys������h�������KWy�!㦝��Y�x����_S~�[�~<����9?;ד�3�<{���M%yJ]v.��K���ZB|k[���]%	3���5�j*J~)�s�K�v{aC]�R~�u��5���.m�*9[�j*�����l�Hh�T�).K��*sJ֤,~޸��O�n?!��x���|Е[G��5�w;�ç���yYs%ꗟeMn?���뛻��Z�T��D�%�DQ�m���؛�)�c��.s;���5�+Mc�j[b�f��,˜X5YSty�����*a�v���ו�Ж����\L��Rb$��-�J����_�����>��^�����ya_rZڼ���y�'`�����?8�E4�O82�)���H��/�����/�|(�H�&i~4
��F>#|ȅdH��!Ag�G����������	~g���'#��e;�=	�I�^����Ɵ���!�ۜ1�豧ď���r�[�B�E�\�
�����_��o8��.���}<p�����?��!��2������o��8�H�R��y������?#��n:Q�J�h�Bg�G��&��w���¼�XP���5�wI�o��;�����]R�+rSq�r����Sڏx]��f&�S��U�	;^�����YQl�~�W��*^�_^���# �y::2 �TE����p�f�L�ʬ��@�{Ed��(�}����J���q�Gjt���˚�w�.&k�F�q���i�:��f�/��qA�a՜�g��X��+�t���q��rg�OՄ��p,j9�ؔ����0�*mw�lO��8��SV���l�?��:3���$�cם��Ș1�z�MB�4���q�#��m���_7q��<�&7Fyq�ZSy���.�7C48Ɍ������(��#���@�o&Ƞ��TZ'u��Vq�bV	"��������i���U��%{�D,�8E�N%[�j��o�,��??�Wy�������b�v}	7�"�6��r�	sc�,�A`���l�H�z�y��}ْ��[e��}-���O~�a��!p��E��ڻ��,��󯦵���c!���7���W~Ș�/60Td��8������&�����?h���T��n��o��j�Z{{p���w��q�������}����c���W��G��#�Ү�O��p��ק�f�l�/���œ�к�\!�:uu��B���\���kcq�M7���u^�k���R9��Q�L�^t��M��#�R8�w&�z��F����S�?���Y\�I���h�E�huח{�Wu��]tXz8�u:m!�c�e�m6���(\���,7/�>+���򖵦�Mm�~��-�q<Xs_f���i�r[�����KJ�ƪk��pЗm������3���P��h��e����r쪻E[h��V}DV��d���#k��)��a���
�cĈ�S۪r����2����{�C�O&Ȣ��U��
��[���a����%�C"h�P���6��!��;@�'�B�'���?迷���k�a�������_����C��FpC!����d7��g��7��7�����e�����{������?�A��
��̍�;�f�l��&�z�� ��?����㿙 /�O��w �?���O�7���SFȓ��" �������_p��,P�_�����9��d�d� ��x\B�aw���#���($@������_������P�����P�����!����� ��� �0��/k����������������	���o�����L ��� �����������y�б �?g@������O�����LP�����P����s��C�?��?.
��0�rB��om��h����[���+�M��?d�B�N8n`Z�YR�^#	�^jf�0H�T�f�JS5p��u��jj��"��1����[�tx��+�m�����U��ȓ$,*5��5���%�m�-q��4l���o��_^�B���XM��}��ϮA�����F�	��R]�I05�N8\ӟX��y{���գ�gv;qR��2Q�v�j�.,��%�����R!�JT�n(�=��,Q�h�㤅W�y��g�*o��fwT[cu_q>�{77�w�E����3?���G��-���C������������>%a`ޭ�(�C���g�ǩV����GL��!1�,�5��qǲ6�.��#q����k��&����]M�l'�.>��8��aS���ݞ�4*:�k�㥢r"�:E�z�[)SO]k)�������kQ����9!��_W���GlԿ
���_�꿠�꿠��@��4�0GB�Q�����������_����v�(��ڪ�<q$�2�����w�/�Ή�B�}m�}����m���6�Y��L��Q��":���p;U�ɲ�y�2S��<3�iyǄ��D��_K$�V���&��]{�.���W��j�<=Jh��:�k��E�]��ӯRD�uv���c��5Yg	"����e
����F����g-8��q"���涠�Y��J��Z�!�4��h>�ug�玳<�K��>�5B����6��[��q��-��j$��,VO�0�6�/����1�v'�&�4wu	S����:?��{�"�?�����������QPd��i�����0��'��=
��̝�/�?d��//^{�A��?���������C�g�\�?-˻������?~���2A���j������;��w�? �7���2{d����1��?� �?��#�?>.
���;㿠�2A��V���?��+�����0��?�B���m�/�������C�X�!G�Cw:\���:3��KS���PG���������ڏ�������s�G�a�_��HK?����������{���o _W�ۯ8Ѱ��θ�`�4O+��3�U��=rzh.k.�麘��e��z�i�4˻����G�ɆUsz���b9��LҲ_�[�~�e�ȝ�_Uήñ��cS*�2�D��ݱ�u<���pkOYy�>�M�~�/�̌Ӻ7�4|d�]w�c#cƐ�Y��wFih?t��XG��Y�Zw�ca�n��y�Mn���൦�J!Q]no�hp�{�8��0��r��ϻ-�?��+���n(�?��Q�LQ�������� ��������+������������x�M�����_!���sB����0 ��(D�����K�������Tv�m�aG����D�X��l�C����w���cɺOt�;����t-S�� ��5 �C�k�S@���J�ͪ\Wu�f�����a[V��]iLeh�("G�m���y8�ە���xlT踻���&c�	��5 HZ�Wj ����j 1Xٚ67e�&�l��C=Z-mC�=Y�IH�m1����i}^樰�v��XiD�P�A�{+��04�.k��wb��~�0��Q���Y���2A����"�y��c����E��
~��������d�dt�&��j���
�&�i4��aV�����`�I���F��K�~����GF������������#f�ҫj���g��D��#����`���b�Ec����?O��vF�̓U��@����g4�[���֔۾UQ���T�s�!ʫ�D�Q��i]�3�4�N�S[������(B����!��?]*�xp����/?��!�'7���/� &a`�M�(�C���g��O�������p�C��T�+��;�H��9�s��w����'j7����d������x�9�?:�	5�*Fk#ty�x�}���u%M'=���6�On�	���#	������o�T�A���Ƚ��UX 8G"��r�A��A������s�4`>(����
远�%�7M����-[��w�(Q�V�h�ü���{������j ��B �k �k+ܫ��v��/��3;��f�j���I��'򩆬ъ�ZT��D��Y0��JW)���R[M���W�ή�mV<�>*�T�q*7�/:�{�W��9�?n�q:&Jl,rq���^ �W0`�<�\?j��~�*y�XS���k���J�X���u�����'W��Gɏf��)ݡ>�s��a��^D>3�<�4a�nJ�����3���ފV�1{�X�S���X���V!yJ�C��l��OBsB(��l,��r<'xe^��v��O󿽍���w6˧��u}��#��	�$]������;����352J�^:�_�>��N��0���QId��̿�E�}�5~��7�#��cz�w~�5��Q�_~9݋T���	���n���}�m��������κ���|F�V=��\O�Fr�/G��'�/�_l��Z����_��}c|��>%����)���g|a���ϟ�N���{��?P��PMm�GI8:Qi�L'�����%?p���n6���2|BB#*�3�{�@�J�m��}ɑK'0�h���<�姟�Uҗ���d���F��W�6���/�/���T�ϟJ��gɏ�ɫ���[~MN��O�cY&��>ϗ�w��A��<��Mi���o}��/�[���Iۘ۠�8�F�1���.�D)ږ����0�����[��|a)��
���xVi�PT��]r�po�>%���ޏ���~������]��1t{[���{������woru��|]/�w�����F�=m�?o�_�/�x�-݉����(,!���5mnԈt���x���uz����~uO��Ż�'�w��� ޷�=��e鹣����a��wY��OJ��f�^�;��[���_�������    ����� � 