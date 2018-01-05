function [net, info] = proj6_extra_credit()

run(fullfile('..','..', 'matconvnet-1.0-beta25', 'matlab', 'vl_setupnn.m')) ;

%opts.expDir is where trained networks and plots are saved.
opts.expDir = fullfile('..','data', 'png2') ;

%opts.batchSize is the number of training images in each batch. You don't
%need to modify this.
opts.batchSize = 30 ;

% opts.learningRate is a critical parameter that can dramatically affect
% whether training succeeds or fails. For most of the experiments in this
% project the default learning rate is safe.
opts.learningRate = 0.01 ;

% opts.numEpochs is the number of epochs. If you experiment with more
% complex networks you might need to increase this. Likewise if you add
% regularization that slows training.
opts.numEpochs = 10 ;

% % An example of learning rate decay as an alternative to the fixed learning
% % rate used by default. This isn't necessary but can lead to better
% % performance.
% opts.learningRate = logspace(-3, -4, 100) ;
% opts.numEpochs = numel(opts.learningRate) ;

%opts.continue controls whether to resume training from the furthest
%trained network found in opts.batchSize. If you want to modify something
%mid training (e.g. learning rate) this can be useful. You might also want
%to resume a network that hit the maximum number of epochs if you think
%further training can improve accuracy.
opts.continue = false ;

%GPU support is off by default.
% opts.gpus = [] ;

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

% The cnn_init function specifies the network architecture. You will be
% modifying the function.
net = proj6_extra_credit_cnn_init();

% The setup_data function loads the training and testing images into
% MatConvNet's imdb structure. You will be modifying the function.

% The commented out code can cache the image database so it isn't rebuilt
% with each run. I found it fast enough to rebuild and less likely to cause
% errors when you change the way images are preprocessed.

% imdb_filename = 'imdb.mat';
% if exist(imdb_filename, 'file')
%   imdb = load(imdb_filename) ;
% else
  imdb = proj6_extra_credit_setup_data();
%   save(imdb_filename, '-struct', 'imdb') ;
% end



%% -------------------------------------------------------------------
%                                                                Train
% --------------------------------------------------------------------

[net, info] = cnn_train(net, imdb, @getBatch, opts, ...
    'val', find(imdb.images.set == 2)) ;

fprintf('Lowest validation erorr is %f\n', min(cat(1, info.val(:).top1err)))
end

% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
%getBatch is called by cnn_train.

%'imdb' is the image database.
%'batch' is the indices of the images chosen for this batch.

%'im' is the height x width x channels x num_images stack of images. If
%opts.batchSize is 50 and image size is 64x64 and grayscale, im will be
%64x64x1x50.
%'labels' indicates the ground truth category of each image.

%This function is where you should 'jitter' data.
% --------------------------------------------------------------------

% Lets flip 50% of the images
indices = randi([1 size(batch, 2)], [ceil(size(batch, 2)/2), 1]);
im = imdb.images.data(:,:,:,batch) ;
im(:,:,:,indices) = fliplr(im(:,:,:,indices));
labels = imdb.images.labels(1,batch) ;


end

