//
//  PanoramaView.m
//  VRPanoramaKit
//
//  Created by 小发工作室 on 2017/9/21.
//  Copyright © 2017年 小发工作室. All rights reserved.
//

#import "PanoramaView.h"
#import "PanoramaUtil.h"

#define ES_PI  (3.14159265f)

#define MAX_VIEW_DEGREE 110.0f  //最大视角
#define MIN_VIEW_DEGREE 50.0f   //最小视角

#define FRAME_PER_SENCOND 60.0  //帧数

@interface PanoramaView ()<GLKViewControllerDelegate,GLKViewDelegate>

@property (nonatomic, strong) GLKView                  *panoramaView;
@property (nonatomic, strong) EAGLContext              *context;

// 相机的广角角度
@property (nonatomic, assign) CGFloat                  overture;

// 索引数
@property (nonatomic, assign) int                      numIndices;

// 顶点索引缓存指针
@property (nonatomic, assign) GLuint                   vertexIndicesBuffer;

// 顶点缓存指针
@property (nonatomic, assign) GLuint                   vertexBuffer;

// 纹理缓存指针
@property (nonatomic, assign) GLuint                   vertexTexCoord;

// 着色器
@property (nonatomic, strong) GLKBaseEffect            *effect;

// 图片的纹理信息
@property (nonatomic, strong) GLKTextureInfo           *textureInfo;

// 模型坐标系
@property (nonatomic, assign) GLKMatrix4               modelViewMatrix;

// 平移手势
@property (nonatomic, strong) UIPanGestureRecognizer   *pan;
@property (nonatomic, assign) CGFloat                  panX;
@property (nonatomic, assign) CGFloat                  panY;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic, assign) CGFloat                  scale;


@end

@implementation PanoramaView

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self createPanoramView];
    }
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName type:(NSString *)type{
    
    self = [super init];
    
    if (self) {
        
        _imageName = imageName;
        
        if (type.length == 0) {
            
            type = @"jpg";
        }
        
        [self createPanoramView];
    }
    return self;
}

- (void)createPanoramView {

    if (_panoramaView == nil) {
        NSAssert(_imageName.length != 0, @"image name not nil,please check image name of PanoramView");
        return;
    }
    
    _context                          = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _panoramaView                     = (GLKView *)self.view;
    _panoramaView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    _panoramaView.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    _panoramaView.delegate            = self;
    self.delegate                     = self;

    _panoramaView.context             = _context;

    self.preferredFramesPerSecond     = FRAME_PER_SENCOND;
    
    [self startDeviceMotion];
    [self setupOpenGL];

    self.view.backgroundColor = [UIColor whiteColor];
    _scale = 1.0;
}

- (void)startDeviceMotion {
    
    _motionManager = [[CMMotionManager alloc] init];
    
    _motionManager.deviceMotionUpdateInterval = 1/FRAME_PER_SENCOND;
    _motionManager.showsDeviceMovementDisplay = YES;

    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    

    
    _modelViewMatrix = GLKMatrix4Identity;
    
}

- (void)setupOpenGL {
    
    [EAGLContext setCurrentContext:_context];
    glEnable(GL_DEPTH_TEST);
    
    // 顶点
    GLfloat *vVertices  = NULL;

    // 纹理
    GLfloat *vTextCoord = NULL;

    // 索引
    GLushort *indices   = NULL;

    int numVertices     = 0;

    _numIndices         = esGenSphere(200, 1.0, &vVertices, &vTextCoord, &indices, &numVertices);

    // 创建索引buffer并将indices的数据放入
    glGenBuffers(1, &_vertexIndicesBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vertexIndicesBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _numIndices*sizeof(GLushort), indices, GL_STATIC_DRAW);

    // 创建顶点buffer并将vVertices中的数据放入
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, numVertices*3*sizeof(GLfloat), vVertices, GL_STATIC_DRAW);
    
    //设置顶点属性,对顶点的位置，颜色，坐标进行赋值
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    
    // 创建纹理buffer并将vTextCoord数据放入
    glGenBuffers(1, &_vertexTexCoord);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexTexCoord);
    glBufferData(GL_ARRAY_BUFFER, numVertices*2*sizeof(GLfloat), vTextCoord, GL_DYNAMIC_DRAW);
    
    //设置纹理属性,对纹理的位置，颜色，坐标进行赋值
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);

    // 将图片转换成为纹理信息
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:_imageName ofType:@"jpg"];
    
    // 由于OpenGL的默认坐标系设置在左下角, 而GLKit在左上角, 因此需要转换
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             GLKTextureLoaderOriginBottomLeft,
                             nil];
    
    _textureInfo = [GLKTextureLoader textureWithContentsOfFile:imagePath options:options error:nil];
    
    // 设置着色器的纹理
    _effect                    = [[GLKBaseEffect alloc] init];
    _effect.texture2d0.enabled = GL_TRUE;
    _effect.texture2d0.name    = _textureInfo.name;
}

#pragma mark -GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    /**清除颜色缓冲区内容时候: 使用白色填充*/
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    /**清除颜色缓冲区与深度缓冲区内容*/
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [_effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, _numIndices, GL_UNSIGNED_SHORT, 0);
}

#pragma mark GLKViewControllerDelegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    
    
    CGSize size    = self.view.bounds.size;
    float aspect   = fabs(size.width / size.height);
    
    CGFloat radius = [self rotateFromFocalLengh];
    
    /**GLKMatrix4MakePerspective 配置透视图
     第一个参数, 类似于相机的焦距, 比如10表示窄角度, 100表示广角 一般65-75;
     第二个参数: 表示时屏幕的纵横比
     第三个, 第四参数: 是为了实现透视效果, 近大远处小, 要确保模型位于远近平面之间
     */
    GLKMatrix4 projectionMatrix        = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(radius),
                                                                   aspect,
                                                                   0.1f,
                                                                   1);
    projectionMatrix                   = GLKMatrix4Scale(projectionMatrix, -1.0f, 1.0f, 1.0f);
    
    CMDeviceMotion *deviceMotion       = _motionManager.deviceMotion;
    double w                           = deviceMotion.attitude.quaternion.w;
    double wx                          = deviceMotion.attitude.quaternion.x;
    double wy                          = deviceMotion.attitude.quaternion.y;
    double wz                          = deviceMotion.attitude.quaternion.z;
    
    NSLog(@"w = %f, wx = %f, wy = %f wz = %f", w, wx, wy,wz);
    
    GLKQuaternion quaternion           = GLKQuaternionMake(-wx, wy, wz, w);
    GLKMatrix4 rotation                = GLKMatrix4MakeWithQuaternion(quaternion);
    //上下滑动，绕X轴旋转
    projectionMatrix                   = GLKMatrix4RotateX(projectionMatrix, -0.005*self.panY);
    projectionMatrix                   = GLKMatrix4Multiply(projectionMatrix, rotation);
    // 为了保证在水平放置手机的时候, 是从下往上看, 因此首先坐标系沿着x轴旋转90度
    projectionMatrix                   = GLKMatrix4RotateX(projectionMatrix, M_PI_2);
    
    _effect.transform.projectionMatrix = projectionMatrix;
    GLKMatrix4 modelViewMatrix         = GLKMatrix4Identity;
    //左右滑动绕Y轴旋转
    modelViewMatrix                    = GLKMatrix4RotateY(modelViewMatrix, 0.005*self.panX);
    _effect.transform.modelviewMatrix  = modelViewMatrix;
    
    
}

//- (void)update{
//
//}

- (CGFloat)rotateFromFocalLengh{
    
    CGFloat radius = 100 / _scale;
    
    // radius不小于50, 不大于110;
    if (radius < MIN_VIEW_DEGREE) {
        
        radius = MIN_VIEW_DEGREE;
        _scale = 1 / (MIN_VIEW_DEGREE / 100);
        
    }
    if (radius > MAX_VIEW_DEGREE) {
        
        radius = MAX_VIEW_DEGREE;
        _scale = 1 / (MAX_VIEW_DEGREE / 100);
    }
    
    return radius;
}

@end
