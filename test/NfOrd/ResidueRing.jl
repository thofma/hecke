@testset "Misc" begin
   Qx, x = FlintQQ["x"];
   K, _a = number_field(x^8 + 80004*x^6 + 2400240008*x^4 + 32004799999992*x^2 + 160032003200160004, "_a")
  b = 157453328191711202179717143189242275793624108621833103830859432521850508785517258526515452488748522153967183119056487054396132867155122761740177908802158675099547151431934600059294624763758643834027264184957820535341431162763941519907431779158236803193945811522853106043997692098093426405229082454664722785808907480264724175884815526238357594511046254584438637555852501249999457786620937165228964704989027947254776067765216999556148943111125818991397160603083469919198030025315667559888127107364666690174293808443184386217103353257704573699505266277037457530643496395683094045211536353669445382975586480921791202703694534779918655140129660198749036344823130279899198691061502640952637957879699193290015968322302901562545378386539245212496404354446799209490150082725279606537550544700416847399414154186500381639700132932451154823563434825463242268221455750656647434479984288711169939596281639048534112060707124336297454374635438390895708762841905290953753671494836962595244948808648592005723571714773940423838991752122171795855325880222182782335186436310850989965002786978614879323179197752257229005252554472912441270233647938921429480611697821876175681621052295915073259515083661087106781966040136882186907951504254075827525085702772154483433836707570725828611969723375545013999128904112217385296350221352953386856894989128166308472902983445905252893966221538870025018899924032939025369772089692749583208376491456598228730258217746346345432835549512991683599825369490774816789860338747941143132002842907630818713097072262516350687694055436984885552070603365530100723585446858085778020890039852777386814686790235929821092765234247832779468651290476876884591829875006215725680377999800045903079829509762028016201542764682224717679952987886670134970000599804330547140587597835336800575064328853338862095081318363302811060248825004911164535958656320384534608387589205269230493242951891073482934975871663490470104398575107356467473788818075360615446936196190310463208540310754085106684177917162736315313666103199860230640063344659800240954181719501239935310150083598234590655996155375928344786242420748680611157496715688057596989653834208522920749000079744952730317119285146975053107460312080156488563955101233561735244432251018294564495097699023073606509919867603667339077921899161071017635232671864586732656855217965616405431949172650503668036696276302057723389447691732125782531206105555766506514020345975959722620912089896153755513385834820373311137868156147940946804503051085717884552161410341604690885553651807049513710899817586736560749028086576850552337162773209230245739699924564770297477453766291689099131649962849718364626175534782623427662584033390429861124936938111280636128211536380298688006401614872909259534534419771411777804432644192342752334889197165424471424206175236286413779883412343452685179477465704722504385989265925564238417167349181629828319029309197565050706983533703390287717617128506776551409336446843836792121070471977415526035073020318789524170145625814287713855005503964657509842766546121254666531447155577544030518646108549421041962810562707496454676876630347872054880482444047586360126367387657334614992255185856817472835003352681710172838570392360316311788131780362499101979580278371162727785425584934020146610880393450964056081473809153768514330091587612658887757204224053332597674250688388631522287649711945971845453870632406886572578269720185843522914648897975740934675808369423713297169203686917053124747616134611834775862229805647642103434259196603925616232654642862869900440353632224631209564243637311049436949331054837801798388425664470865382478669165//46126479297897394403*_a^7 - 109129017500735068097485652403006129583338152036591670435148012836571470650560793838107931179065097972373276502621774054923242288113421613207721950481979960990097133839578593997363840254679436991395383283105548104609012882083019875052357667778879870808978267529112054072856463084456046589237240241535410976165607160093510161702875373246603604361638521630312812502919370616305461231999559909728268087747088573098659559957248866641089359066983448774404497913970249327257245639090120944621910596865606263253377991657518350165512065424706905569389036925614986502296765268000367173727631683456463493115355611812250697728236308440843052321162554698413317189611511894312615017228370087170634431297977781212368289780382111032617340306810121538204487701247009733519039439523043587025463744251786974155680349902283153283662670452024530450583502062350434459008403308261126133746156957507540304842941813219935977897153768443225520969482580227387613713727792824868524894022621913854827007279593008412789080817996220812386149493196194281145516427634406035826126211857562169065276829722143571228729508429477903891765890596948910589536324882170034816822708923655009944826984616102489096576379080598917851994550155100921865715488618659650981781714112815554729838883000634036824840611225522831725194807477289803555175988010593681065694689850359166279161923217483805422125643777610157697264936513041972038981014919871073728140509055976425907616337652889090635421456868890051551232157912897736011442976463923643733640409514756627598713931877426819027037108065074481505842560914564157885303260289585629350271289261689973651935183190398511920543939582841513869389341557779966065564386554486521240704599537991160833027259427669131698584060458351750932793651200072225531279912657128345794784083198463146180456612238796386559628498008301433313238745213772811419625156129621843671496474288128418016768704420840626065971675506178103016194527455628785058623689929873281420373121817509218257899468299339430981870558764406393558198912709524986280924707115434487757122963764507647540759073625212219641818903058579337350979807857440188158790653645478023864693629542869388344155752763588233846264606585001719348002856272406233474334974948933862919037363300894938036369773799787583762002515019412037011543581002665007213728126161119666042693356480272678029984369884401315756761277668139960177462619921409167011439759429429794996282198091977010033647664692539874639452154158814697664906336957410898474255250500448661298146818686367425265410437870185962760510770035060195742166260552979574685852809221032688296344603298954785675889739218359795034303214707683774940514574584244708783899750181446905350845005210364287458287301365915156135442059841379086659004121848171107840428810702720517720099182459434527790182361515252780960013105179252114955811899744893393289560702018955568963607023178075130487008405702330459848453963614052715498590599693024714227516587109137301697887087036044486345573958729536870330872538761244442294085468287095146646019242589295206315846435434424287520866106338262458736136878683460739751346826590175770213677066275853437961491431385598446783113473120423643677181313594941062203721776630757041025029813432208904997747375912374601884995881422273420026528000530350679928171133787283704677159816849590245091776638533203061126891600692610630250524001514961799305490531635405229662326818552059339317961646076793852885198426380891822205965239404133701088460001267695332502025034563870530106973046246579603361499791538857080140133076632812374645373489767979026090825246364695638611207296424104458432//230609334403*_a^6 + 9509875485162859936462490814603025225212201306280916742489087666337544199602872686216563375530478612520500142477443417402489329613822060396293826870278353856146636573967037565429595193211078037642125448136934529286638915938008933803592794216740484752209047495907984649036332814480389855118382592984959453365259860078932257367570163848153925920848367238925270678579035372303290120032261195237737691209290526793473291776080296376423200979905584688493290449025546932640461736364338453922499689721643422770620413561905322463520614658183873060085456050483423634400373547139398679379235181169399027126065384421785672510957170422572808607568916442709677573267740951835490838800739890798170303665902539525126301786063840467322248957951230574279330965261616369418575774715493264432416026809500426291016470707953096750102495111745923250409024425357126408571517673577944959593277664508600847306477419161512425796574852471956027361338657479335649267239289944488502153169488712833025512970306763384029534434561753014094786443012051566883948723690308381828289370799539066165166286168588209763420625339408277689252294430292823911015570054665860552661934248072769461573118422297378072785322252798609357605231843402910834160904087472526596300163449114856040780936018364541233673195667568564507425641802572550673528038958946527765756970053895422286868044271357557984438231726530774986232715559899128931666510596940555089494209262889672421429382668300226613152283348963899408016786805759268664269501809861219831200486717973086738415981830449132530296568795497405338162465338409821827738353146444807085435996075663291570858754494282524531599150697792280619735148471820448255178468026277513843610757518132478919601115856079824974171561574967058136802387466312722719419313194982250487383176635390610361824228851023707820255400218859694470642822268166244186589457574186677459721565654920333721336463980376710790361157665549871194459850387371437108326138861206538763818371790048923922211334436923444567455078513019794038098888702836457783231116035491817540746906006460023209826930074385276768402626025346227666710771154082445798814779546095799678020430150932068802068375912133789868407502665960048944091845327794732918197109045983197415905391192377072876166066045340201275390409507499088123694949661734617092489007076013876287684771602404750624394098931941047700299281968670979437632429418459485954336519831694945980284330154389420004010401361884054953118188814873083592617731302599744306457655453963757484708602200969443957436081949903443912266347309956871487047156245420453960363052836530784031388852286502526656274793087482797127397991025277808169350267132775777721013419806719363467801992285764603283248068671691404357745756053141273230087788038787177765037303953440693828153578164559929408845505013147926319785455235318510047637983610707402164933361201854894571814638488274434214591605469177533624660196216566153536332457321342209570567371582859099606123052466494290871890692407750661240715567698612559057909988038745378422557594827405335936991221107566768918528839677574632838686244080331124086101084426938644588303426883415656585011048460470402459061868016794634745438862799232392067986750551201639144447103955954342131005399297173640581810249782927107154949580744656685298056299115698166488639817681305940574659784304438283263965984295205684742477383928619331876203673449107572981614775125231078819431031158764584957893685437379363152617137968115952107208574341928852582476106512893851838176010005145264060726414424983247666799717096972426582713873170210326231277632836303204988034868328350902586781100712180//46126479297897394403*_a^5 - 6547959308079105555985334115485173787259455798499573409449751066219961381974948751874152086606264008538341336710311686843504383771381523635689732472819761619327808224642394797029825142961275578357705787752899097372749990950745358542891564782068350008280314008281781468479533497993531707447412888972607729391888760819930796722495928145542709468907034574862029375800168075719560284842437593703515541801000808563065770916554846496198643722737140893361818683834042900134089252836685436919203879633130107007729186255434416046631054949613263747974480993610750420110810509610558031158005356270754722513907567419958666365089634979067464825374395607014195858011069936682545526263736661970412407146741262828304522123402487426179105653089220912535345671050223078030609404450261661308701875582595722023289132354836793763326327552462375876095911290745150768409422215302284090277036909764367433371186194676822598545785020414130417709210893778803711598051095025077761230691145360075117330090790139690784170427241409241184793741890758049257293276690919630961639224963877445268254740336988058560866227964785533189313736967598128533193358565579966429078996180837147906709508730935381550772775897594096268955376998406365513786660748096816378208866410197158914899792657804043477564086354753820949175138838252342792917669632611642051303812780401250695082273716895463292938382877944164682151290720655544406282938857222104165835886824376697507308795491848651216306558255047140873177031939089689956158601473788346471305891851704427169178033340509363995260280558120599039313565339995678601433966223895716932274977898279921799063414861790291512256477462849656515191099272149913523865994322042300247484757381478545632303301620179003240178440795622021759469484659306733676327857319253015004378634560074185697119757647552260786350829137494102601660951190316796230800348618089569863977131450236281337842155802659279245210432473721698537177704036392638361087538643172256631785228055294188113910483896896964537774197266981912426279051160396918226828044276340300134402892071797987867740625935659983602948417821320877399733490431062126169903756800035972387929347159831249039426033477320821207243568924313273164318867382056918820927047166885929642868079872780298072058259167534854600887674906194761044766637947321905762838115025919502201893686775529321227155122161803847748037190182643733890568112120524392839020408445284646559366924449914804556038927176881777558116408153837199489289710030118568730252263540527920575211405414819418250775157093086898137556167223643681864921459965699880440300540258880403363157268887143885050124736132580024421648261488890441863980755504203851016451552810387177214861402002632277976072154656557641198438794474602427957713565319133962812641409499784636504241391145930990536466522055638197363162706336965485401578625608493093384160221242541372048954348604730863979481478358951232251826934724770391035346433162780868903079450259722456376476620996336741269707128671689671293593014070752189026529716268162282989054446593842890969363417818936326099827008112508424049085684994765011306560312289063726564361051330683757984565408865998678003880374614171659467918233178323653614347714041398683975583838865559398717674838049494300862303522877099249748431733087822101497050124369504596848038943330609113885996781865269250073735749824758023036291941138900737881928042879187584590198933766760664477756334687899784760817675979706271116002326294726830332709776996064255340786506123901359547478596720887269360896710491914502522568264864122008103471700133058277523501696432374467707949660200039115714836864//230609334403*_a^4 + 27351928385067938006765558531439846444319897633555181513639547852926415394394173988631211624240563072249206935444196044027300964775256946052401956648436334626276849827308365062570808368089117881452119397407201830501974535054905796769478459021596900123153791684492824954358613364323118542477026214044689740370893669991460155381086886800728093489249431389538723349204764514796095181236427412710062947592696089916493665703116755301392240662231431757176826281157789635123995853642784556579673360643420861744784464674152825645314049842698793248642240631588594980286354227421434525989880584606075809695212849707261282427778433940692040452467875075836833221647259958459532557057883565484468251071662584876061338015158003747064855815371261645088703854145503259244728671525515753856848226902935077583442222396506137790041817563294343380980702484533090224730979007604739630159414136877019291284749179348526532291491730034929605335471483445995252212845617701621638505823750792728756722077020374923860923578620746763439487396735105911609623743006991725318960074235259237009460661409184014229422297341000405169401780548541112339649802576096890062776306248041623835351301664729479343044592532011091089101529037674705944136891942572428641611099543266414500771623598985996726568686681857808947069451093323302933179557264224691852170299465180715931241050549714892868864751501566969060834339767817721833041556117125232604953347509243634724877691505460166753056824735124045674381218677040396531403504859870575678536580096135981111145719419585185295276534370961075592605196630963069390734605734480619049572284787354083641404380963265554310117228122637021555905366117547924264803894909744088733206530653637116358809804188087537449527905375913982947794335218641612258244122729667523113671851306820415659571218839415843228520143073256829116132059954957795690531175957506078413740462579206819187713174216228434263215756367781440756230609548836643326681088982394989159574543275192730278192682126410996480940436990057933014407310586883682641396201032237173447881556106763486711271224736600229812684045389386537343080085030588080039393935572451758612297264678392680935685927791647736821631685393342765857872212927400905915029353865225711080711187937571408096542284760714491977927747638420942828171807006787827965945341745218466859619265890544529107984603968713163159027691484205835321795814113086527081481712888458753226374588229942341397610546415428916099430509826744483759933736975034172980689113916862967026820256348111179438215258113127295478740707216526552338077158245116462412625889254200382254031826374073657455859187114388723778165515349295593882177668987290207961750632777642831439066114978459318350665279310884562136459389311235817898320940373878794576566955184257865168555041907920076570883220058040110141954901898709000859346371088747590128115674499735688969774837506603462891554466692476395835261484918664973398584660743322141588214797054096162667509227138760300834402952805392794524264841905594499930725155983859803048758930524144131942987128005539781924665907949582902546669552152568276111357851327655405666795200063045647696266480911395501956076204976616399805153033055175470015365673076148734951517588426454325582262995830393447484367277572805607022317298159233847482657194421091018267447248774355586307338979027227591435600261621495216475675655715890711921778054601401578290804540182256244918345136757436638197452833421577960766679408750639018592954637812545252297151835651129224169989901740005581428564958702967661958356771809505920623578130987955205214503925126099394733458675514742059765754079545734850//6589497042556770629*_a^3 - 130954820782624046715512646688636050693993523277233700448994274533589739107530011304607929738662255208717735858399575860664342635889621359622423114162932052224156638627300045117679420310887643880315585956935891159319719249281598085896789451229940509413014179416977929829203647555634329738172595111368012688327906639780997873856430124490173578740759017233098331742877619733727812245788549427674801885839970112224214325751379520054809497598201420395318499947955303364768196112393653855366050826994906322172841063482266036883577778178624155833853033171959909951526145317006910072472423672692492824825499747943989613649382174672539045903708960995770871230707179893952114232048814070148021143216304474858886385311721953678376586302937465232225142165087436277728827860389573425384469319051216880483242471571379084135828897975104095636651141573653517226109215051896544743973136081516734450796449566178039547036712566337563088276928054333899976001698123962386644223090096508580548581025857595536160880156017303338870937767063134150982231150870254387722539382576822179163207857536018626030188267657914467811163260932806911513545768679531392015847181074740594086482361649669017683686676703565943261195624482132005928656742610960603940818754971815237450175550141083078188540659820946175619188105522358149311631578502360441257646265689041619834275975302656720071583161688880901681497608421120493420693273825883258634026463410890692977186753368234233456727566971825148123698486393012967387936099733822419552521203950427134088943463055484319077590891624015161676862110085791867633235596576896234641154288413485389858942272524607847923855703658321937477584182130557276163117331734255052379872476964180193923650389647148439182962609152853980202648879574499368237391444125994189639484208248587609019621642325642439393961424490704723959283627630049883276004564516295900146552081802761153043865609271471342437484758475470372607077226914365487159090857798600557844701183340264818274460925443408380579565808553546554741025908135032158118059675976671971077678581003163249519895593268736516319758244386657398704017094726968610075668408056992321346676307722056006927248126627994375088341060209472850047599988830881767624389502990050685604977110122999199041853852487005552914827850499289414375028223180110846651143736965887346928992695690940500675435887801312839139310901688245396876675223550765760570909377292436235136679047717808015856423177563752520182262835711673328880258209019080404254284503652027892556878859827347272945757674913402279572240998521050694820479121179242968517064221693533607513548147366056536213158115710252275604444267580614100513249939620064501372190282649936786058120195550747134529216186722523584630700159538770784308046772899797085712172357162406999858677983511123068429349778237938614121510164295076327588470049782248272457686055843625278718417289886476110228259825868779740413483836639955331370203288634448457686970476075931587819189901047479209542599777784296326937973305851748253230413677356343239401032797815115762400425309889616274156190752564182737806839336947879130334694712405517271076060939103669993002082841739735273368539274178281426171770288959566647454584007549464895968521694068591059132879041099354770437245853936736341187286760583364814853104000688398178038024370865188660410951476056290396285863798577349554915407541316906156136665039351505212323981722937817570077435296656229331308650405886673333885374642873029962497884599344314396467039376472594567000626595281949431540640543123628913090445531679108696308823438430827851773032243455984273604057478486510757270191083136//230609334403*_a^2 + 1284946355115194463208875703880150901544562270873945882343608230372892380068600875536309172687272909300258885776022344545646867289840405404787169624761585015447329052682368457916644505126484036891742265297471118447081184446936061822177640827110723510183089692666685487877799858590629217098973515817454888860640016128233562905183205685051023317149686640586983633509724952981986084234981681801723072850599798378266981266025981402184633453788917134592203288968541824697064396602186097820536279603364574718102218627912807227313199244557330236284352999359938337469913350315701924498903817190936701567877033872889845665500448869141783112724783795501257717247909229775739929906036033536775926871070192724498034373054784741108501447157078880558119858467292388682305055466472846649501741796393138064394067475164348934444753048726585742316885411649154264993418591918969131612798702735704363672556868348376008607553429814995469530882077046582470630914774507412143281771021937357396960878020679437606477414600977707823002355247011310493915541742269904637272049337057480528555480151611443132182605401050743563925681412075285534721328936601522166816316463336838178336487382229837878334440332569623256733519638018118699553337056088723264572781743600707445692642838083073648604399016944501217042309619888564441291931673192526366022720063335468775024858755473621597865388882391472525702882299447428233741818255289213481840235453429620477800181722385647827482860828384008301226457046846561111195375111085579171424327130987931709629245191357393658667460168225466849729027555597965573315275854198688023327551884906430991278083254550633908470082717994676027535083809217901279741326829162847142967619355998159511280321888012200209549706499439207933871471847249958910879309351934159882148462933446306923487115462544097540652560031051619507982236105021839595997728609005643465179891213823399349429303054286048613828817418251609270654199516329646718199088856491289893281476430705774908168202032361603869657413602440273445379151438506432977293945367816438347816442265207570136112850186637418555538054143736874681813307869217950105579661963317241365563171196923711349590562180098525785095868512535945548873189195198489703415914471089508914067427932011227790694446523747779785380634021494514331121922015867722473933371393964662584699928799139375264394768894669376020645205621828355396024543171745411190871465795444108208432386822513265247465655532942721244442616933594323370532078722999130606131951375458933835478617699855765688886124401743685943473319428487418103902085862069901407614833427977324074462589506682407527144826107875195202333732296475372190196712619262080898041987735242303144329734130977941408623104983250163565381005020214452819911105874789195046897658358526721420382117952517446520168881106368545001023676318586088953960087796381774549073572026569278145522973604375049735181328995100136677970891308847255095976319274741454162530415519179037093463768531780725829826922570033597345299571849936165204399808919299935359507504075489135460009480229184278964093473638550140227994742963783665016674336643162189365280444395937787661496190031883805214124390606094591010098351423504840709123731032608454785755569816102323461753131333310812742838981309971636977218301990217347740021444685046116804182531758541411936510894492857776217720805315344289273550562972287883288970555639603475575229799634249498918400388552299477072136033299197047784578292818020776377101336896850569627466819921235541420714481137583369026200944058085265708419372014173936873191966501687254783926824037945662577454535205685126168554103746829074441060//46126479297897394403*_a - 872941305025909256259927895497336456843160696671035497593832080786102286003505246772783290374135343783357039513551169720110583750401816648328691369395901686450808725988360082406589108618367963754967499360087155297451742255316916674867967946916356764938379913370308047478143573630160532898023617998091675879238917664754910736523627875086164403650962017943365177426889973569838839383984144190731285162338592087308536788469232671447518793042968567188617270153069503488888661657353369078164936685635575028664354414198899306796682471649110158000972389146838267407288028673357921881412265627264109298265555796856764816957550463197951713393366631193918583672504327651783069050335442360244265690497695993624047708010088414500423143674150832204869374075515069301554662787220224454313321909948738525308694320337515181568000029208132005803914998169092119118832575241908754510034970856487467311674572928094372808990248630060126186483396939435412355948340163601568664820823909179808258957745880837485220931841369495124584956693231045945576494825564108958049902698618659758028396190313463454231455571817267169596127023086721966580102528352621066457268606165886839047480332145407936229001146492863508509489175061551498350823812764370245271291399141761606824395242859941394032843380442587930307078323501747086151711579124147811174440572516575194268812162252049197216736639128510683775829155188777575121728018291102938969614414138900407673723315465313095258730094197916506221926848809813052048772510269322783004545349994942928910682240163448317429934024374979089629234179704761734607774039471570296630751924745207383141494241292710826267905802774995917348511663449488120001731251343981888592294121839518230351645262807578661854987340118795812751558636549365188844968035107062051936036649506177651007596207676541593107777167335298829539692999245445857507765435079770142349667117334911610639558461298537127403991713249070309850348795686580281673322272378450241835278551418589149296448612993945737533359862348733309165985290936375840777705058720435776621203704246126978758593235686308123741754428270806563486128184630765930539017403483213863525622295237692002941927284861767004036932839647362091296506909746657278127348659313232307554046547204630231845655955319826690235264313988133320518767638189565314418608088625408595788058320173684821108942415194349930749505973903344183445486385622909336533393835742026666858236907285299213790298301897239165579779878885701046422754158670095708825120172838344770434288080358775010112440405235662753328320798468086484518960221999398213635466595444534677789362366406183119986503384732758331254797749920049151197926967141286819821670763291960669331253558703635929057895383580668458223426459584234804121872003680519647021808832479786408664219592661584508933891104725619297386877335317318324348258063359758243856661577358170725370799807557736627050949884003154921544246326570016950175894272713853780402571380264485503930269741447366518275461087979690052989261955839309071266734788013402457769168451977105899643154003021194094250668928827123931962215939682075756620977405078861994248628810029176026481828451208736419726540076063890160862253993414730343075229845663314587708901515808964415081962867569689803243407073910339343406291433359757750488726388100139748794716034176854991228078435330801043788060921840571146195310383532162795933534681181333029604541590079714907666392314405393189520278482084992715410795148922628471457856857621075723283551487319414750392916478335797266706719854087147131211814897472009961485026886211575132505232693187275713350247096535066511807635233895912//230609334403
  t, c = is_power(b, 8)
  @test t == true
  @test c^8 == b
end

@testset "rand" begin
  Qx,  x = polynomial_ring(FlintQQ, "x");
  K,  a = number_field(x,"a");
  O = maximal_order(K)
  m0 = O(9)*O
  Q = Hecke.AbsOrdQuoRing{AbsNumFieldOrder{AbsSimpleNumField, AbsSimpleNumFieldElem}, AbsNumFieldOrderIdeal{AbsSimpleNumField, AbsSimpleNumFieldElem}}(O, m0)

  for f in (rand(Q), rand(rng, Q))
    @test f isa elem_type(Q)
  end
  @test rand(Q, 2) isa Vector{elem_type(Q)}

  Random.seed!(rng, rand_seed)
  x = rand(rng, Q)
  Random.seed!(rng, rand_seed)
  @test x == rand(rng, Q)
end

@testset "projection" begin
  Qx, x = QQ["x"]
  K, a = quadratic_field(5)
  O = equation_order(K)
  I = 2 * O
  Q, mQ = quo(O, I)
  b = FacElem(Dict(K(2) => -1, K(6) => 1, K(3) => -1, K(5) => 2))
  @test @inferred isone(mQ(b))
  @test @inferred isone(mQ(O(5)))

  I = conductor(O, maximal_order(O))
  Q, mQ = quo(O, I)
  @test isone(mQ(b))
  @test isone(mQ(O(5)))

  A = StructureConstantAlgebra(x * (x^2 - 113000))
  O = Order(A, basis(A), cached = false)
  I = 2 * O
  Q, mQ = quo(O, I)
  b = FacElem(Dict(A(2) => -1, A(6) => 1, A(3) => -1, A(5) => 2))
  @test isone(mQ(b))
  @test isone(mQ(O(5)))

  I = conductor(O, maximal_order(O))
  Q, mQ = quo(O, I)
  @test mQ(b) == Q(25)
  @test mQ(O(25)) == Q(25)
end
