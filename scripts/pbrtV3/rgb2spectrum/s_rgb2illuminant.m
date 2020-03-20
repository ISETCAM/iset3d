% s_rgb2illuminant
%  
% Description:
%   Scripts for generating and saving illuminant spectrum vector.
%   Data copied from PBRT.
%
% ZL, 2020
%% Init
ieInit;

%% Hard coded in spectrum

% spectrum vector
wavelength = [
    380.000000, 390.967743, 401.935486, 412.903229, 423.870972,...
    434.838715, 445.806458, 456.774200, 467.741943, 478.709686,...
    489.677429, 500.645172, 511.612915, 522.580627, 533.548340,...
    544.516052, 555.483765, 566.451477, 577.419189, 588.386902,...
    599.354614, 610.322327, 621.290039, 632.257751, 643.225464,...
    654.193176, 665.160889, 676.128601, 687.096313, 698.064026,...
    709.031738, 720.000000];

% RGBIllum2SpectWhite
RGBIllum2SpectWhite = [
    1.1565232050369776e+00, 1.1567225000119139e+00, 1.1566203150243823e+00,...
    1.1555782088080084e+00, 1.1562175509215700e+00, 1.1567674012207332e+00,...
    1.1568023194808630e+00, 1.1567677445485520e+00, 1.1563563182952830e+00,...
    1.1567054702510189e+00, 1.1565134139372772e+00, 1.1564336176499312e+00,...
    1.1568023181530034e+00, 1.1473147688514642e+00, 1.1339317140561065e+00,...
    1.1293876490671435e+00, 1.1290515328639648e+00, 1.0504864823782283e+00,...
    1.0459696042230884e+00, 9.9366687168595691e-01, 9.5601669265393940e-01,...
    9.2467482033511805e-01, 9.1499944702051761e-01, 8.9939467658453465e-01,...
    8.9542520751331112e-01, 8.8870566693814745e-01, 8.8222843814228114e-01,...
    8.7998311373826676e-01, 8.7635244612244578e-01, 8.8000368331709111e-01,...
    8.8065665428441120e-01, 8.8304706460276905e-01];

% RGBIllum2SpectCyan
RGBIllum2SpectCyan = [
    1.1334479663682135e+00, 1.1266762330194116e+00, 1.1346827504710164e+00,...
    1.1357395805744794e+00, 1.1356371830149636e+00, 1.1361152989346193e+00,...
    1.1362179057706772e+00, 1.1364819652587022e+00, 1.1355107110714324e+00,...
    1.1364060941199556e+00, 1.1360363621722465e+00, 1.1360122641141395e+00,...
    1.1354266882467030e+00, 1.1363099407179136e+00, 1.1355450412632506e+00,...
    1.1353732327376378e+00, 1.1349496420726002e+00, 1.1111113947168556e+00,...
    9.0598740429727143e-01, 6.1160780787465330e-01, 2.9539752170999634e-01,...
    9.5954200671150097e-02, -1.1650792030826267e-02, -1.2144633073395025e-02,...
    -1.1148167569748318e-02, -1.1997606668458151e-02, -5.0506855475394852e-03,...
    -7.9982745819542154e-03, -9.4722817708236418e-03, -5.5329541006658815e-03,...
    -4.5428914028274488e-03, -1.2541015360921132e-02];

% RGBIllum2SpectMagenta
RGBIllum2SpectMagenta = [
    1.0371892935878366e+00, 1.0587542891035364e+00, 1.0767271213688903e+00,...
    1.0762706844110288e+00, 1.0795289105258212e+00, 1.0743644742950074e+00,...
    1.0727028691194342e+00, 1.0732447452056488e+00, 1.0823760816041414e+00,...
    1.0840545681409282e+00, 9.5607567526306658e-01, 5.5197896855064665e-01,...
    8.4191094887247575e-02, 8.7940070557041006e-05, -2.3086408335071251e-03,...
    -1.1248136628651192e-03, -7.7297612754989586e-11, -2.7270769006770834e-04,...
    1.4466473094035592e-02, 2.5883116027169478e-01, 5.2907999827566732e-01,...
    9.0966624097105164e-01, 1.0690571327307956e+00, 1.0887326064796272e+00,...
    1.0637622289511852e+00, 1.0201812918094260e+00, 1.0262196688979945e+00,...
    1.0783085560613190e+00, 9.8333849623218872e-01, 1.0707246342802621e+00,...
    1.0634247770423768e+00, 1.0150875475729566e+00];

% RGBIllum2SpectYellow
RGBIllum2SpectYellow = [
    2.7756958965811972e-03, 3.9673820990646612e-03, -1.4606936788606750e-04,...
    3.6198394557748065e-04, -2.5819258699309733e-04, -5.0133191628082274e-05,...
    -2.4437242866157116e-04, -7.8061419948038946e-05, 4.9690301207540921e-02,...
    4.8515973574763166e-01, 1.0295725854360589e+00, 1.0333210878457741e+00,...
    1.0368102644026933e+00, 1.0364884018886333e+00, 1.0365427939411784e+00,...
    1.0368595402854539e+00, 1.0365645405660555e+00, 1.0363938240707142e+00,...
    1.0367205578770746e+00, 1.0365239329446050e+00, 1.0361531226427443e+00,...
    1.0348785007827348e+00, 1.0042729660717318e+00, 8.4218486432354278e-01,...
    7.3759394894801567e-01, 6.5853154500294642e-01, 6.0531682444066282e-01,...
    5.9549794132420741e-01, 5.9419261278443136e-01, 5.6517682326634266e-01,...
    5.6061186014968556e-01, 5.8228610381018719e-01];

% RGBIllum2SpectRed
RGBIllum2SpectRed = [
    5.4711187157291841e-02, 5.5609066498303397e-02, 6.0755873790918236e-02,...
    5.6232948615962369e-02, 4.6169940535708678e-02, 3.8012808167818095e-02,...
    2.4424225756670338e-02, 3.8983580581592181e-03, -5.6082252172734437e-04,...
    9.6493871255194652e-04, 3.7341198051510371e-04, -4.3367389093135200e-04,...
    -9.3533962256892034e-05, -1.2354967412842033e-04, -1.4524548081687461e-04,...
    -2.0047691915543731e-04, -4.9938587694693670e-04, 2.7255083540032476e-02,...
    1.6067405906297061e-01, 3.5069788873150953e-01, 5.7357465538418961e-01,...
    7.6392091890718949e-01, 8.9144466740381523e-01, 9.6394609909574891e-01,...
    9.8879464276016282e-01, 9.9897449966227203e-01, 9.8605140403564162e-01,...
    9.9532502805345202e-01, 9.7433478377305371e-01, 9.9134364616871407e-01,...
    9.8866287772174755e-01, 9.9713856089735531e-01];

% RGBIllum2SpectGreen
RGBIllum2SpectGreen = [
    2.5168388755514630e-02, 3.9427438169423720e-02, 6.2059571596425793e-03,...
    7.1120859807429554e-03, 2.1760044649139429e-04, 7.3271839984290210e-12,...
    -2.1623066217181700e-02, 1.5670209409407512e-02, 2.8019603188636222e-03,...
    3.2494773799897647e-01, 1.0164917292316602e+00, 1.0329476657890369e+00,...
    1.0321586962991549e+00, 1.0358667411948619e+00, 1.0151235476834941e+00,...
    1.0338076690093119e+00, 1.0371372378155013e+00, 1.0361377027692558e+00,...
    1.0229822432557210e+00, 9.6910327335652324e-01, -5.1785923899878572e-03,...
    1.1131261971061429e-03, 6.6675503033011771e-03, 7.4024315686001957e-04,...
    2.1591567633473925e-02, 5.1481620056217231e-03, 1.4561928645728216e-03,...
    1.6414511045291513e-04, -6.4630764968453287e-03, 1.0250854718507939e-02,...
    4.2387394733956134e-02, 2.1252716926861620e-02];

% RGBIllum2SpectBlue
RGBIllum2SpectBlue = [
    1.0570490759328752e+00, 1.0538466912851301e+00, 1.0550494258140670e+00,...
    1.0530407754701832e+00, 1.0579930596460185e+00, 1.0578439494812371e+00,...
    1.0583132387180239e+00, 1.0579712943137616e+00, 1.0561884233578465e+00,...
    1.0571399285426490e+00, 1.0425795187752152e+00, 3.2603084374056102e-01,...
    -1.9255628442412243e-03, -1.2959221137046478e-03, -1.4357356276938696e-03,...
    -1.2963697250337886e-03, -1.9227081162373899e-03, 1.2621152526221778e-03,...
    -1.6095249003578276e-03, -1.3029983817879568e-03, -1.7666600873954916e-03,...
    -1.2325281140280050e-03, 1.0316809673254932e-02, 3.1284512648354357e-02,...
    8.8773879881746481e-02, 1.3873621740236541e-01, 1.5535067531939065e-01,...
    1.4878477178237029e-01, 1.6624255403475907e-01, 1.6997613960634927e-01,...
    1.5769743995852967e-01, 1.9069090525482305e-01];

%% Save reflectance spectrum data
folderPath = fullfile(piRootPath, 'data', 'basisFunctions', 'illuminant');

% Save RGBIllum2SpectWhite
comment = 'RGBIllum2SpectWhite';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectWhite', comment, thisFilePath);

% Save RGBIllum2SpectCyan
comment = 'RGBIllum2SpectCyan';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectCyan', comment, thisFilePath);

% Save RGBIllum2SpectMagenta
comment = 'RGBIllum2SpectMagenta';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectMagenta', comment, thisFilePath);

% Save RGBIllum2SpectYellow
comment = 'RGBIllum2SpectYellow';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectYellow', comment, thisFilePath);

% Save RGBIllum2SpectRed
comment = 'RGBIllum2SpectRed';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectRed', comment, thisFilePath);

% Save RGBIllum2SpectGreen
comment = 'RGBIllum2SpectGreen';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectGreen', comment, thisFilePath);

% Save RGBIllum2SpectBlue
comment = 'RGBIllum2SpectBlue';
thisFilePath = fullfile(folderPath, [comment, '.mat']);
ieSaveSpectralFile(wavelength', RGBIllum2SpectBlue', comment, thisFilePath);