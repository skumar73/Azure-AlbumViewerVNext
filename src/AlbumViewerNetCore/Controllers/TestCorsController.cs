// filepath: c:\Users\makizhne\OneDrive - Microsoft\Projects\MIP\Azure-AlbumViewerVNext\src\AlbumViewerNetCore\Controllers\TestCorsController.cs
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
[EnableCors("CorsPolicy")]
public class TestCorsController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok(new { Message = "CORS works!" });
}
